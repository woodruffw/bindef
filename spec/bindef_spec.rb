# frozen_string_literal: true

require_relative "spec_helper"

describe Bindef do
  it "raises CommandError on an unknown command" do
    expect do
      bindef "nonexistent_command"
    end.to raise_error(Bindef::CommandError, /unknown command: nonexistent_command/)
  end

  describe "#pragma" do
    it "sets a pragma correctly" do
      bd, _ = bindef "pragma verbose: true"

      expect(bd.pragmas[:verbose]).to be true

      bd, _ = bindef "pragma endian: :big"

      expect(bd.pragmas[:endian]).to eq(:big)
    end

    it "sets a pragma for the given block only" do
      _, _, error = bindef <<~INPUT
        pragma warnings: false do
          u8 -9
        end

        u8 -10
      INPUT

      # There should only be one warning, and it should happen outside of the block.
      expect(error.lines.size).to eq(1)
      expect(error.lines.first).to match(/W: -10 in u8 command is negative/)
    end
  end

  describe "#str" do
    it "emits a string (utf-8)" do
      _, output, _ = bindef "str \"foobar\""

      expect(output).to eq("foobar")
    end

    it "obeys the encoding pragma" do
      _, output, _ = bindef <<~INPUT
        pragma encoding: "utf-16le"

        str "foobar"
      INPUT

      expect(output).to eq("f\x00o\x00o\x00b\x00a\x00r\x00")
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.pragma encoding: "utf-16le"

        bd.str("foo") do |enc_str|
          expect(enc_str).to eq("f\x00o\x00o\x00")
        end
      end
    end
  end

  describe "#f32" do
    it "emits a single-precision float" do
      _, output, _ = bindef "f32 1"

      expect(output.bytesize).to eq(4)
      expect(output).to eq([1].pack("f"))
    end

    it "obeys the endian pragma" do
      _, output, _ = bindef <<~INPUT
        pragma endian: :big
        f32 100
        pragma endian: :little
        f32 1000
      INPUT

      expect(output.bytesize).to eq(8)
      expect(output).to eq([100, 1000].pack("ge"))
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.f32 123 do |f_str|
          expect(f_str).to eq([123].pack("f"))
        end
      end
    end
  end

  describe "#f64" do
    it "emits a double-precision float" do
      _, output, _ = bindef "f64 1"

      expect(output.bytesize).to eq(8)
      expect(output).to eq([1].pack("d"))
    end

    it "obeys the endian pragma" do
      _, output, _ = bindef <<~INPUT
        pragma endian: :big
        f64 100
        pragma endian: :little
        f64 1000
      INPUT

      expect(output.bytesize).to eq(16)
      expect(output).to eq([100, 1000].pack("GE"))
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.f64 123 do |f_str|
          expect(f_str).to eq([123].pack("d"))
        end
      end
    end
  end

  describe "#u8" do
    it "emits a uint8_t" do
      _, output, _ = bindef <<~INPUT
        u8 1
        u8 0xFF
        u8 0o5
        u8 0b01010101
      INPUT

      expect(output.bytesize).to eq(4)
      expect(output).to eq([1, 255, 5, 85].pack("CCCC"))
    end

    it "warns on negative" do
      _, output, error = bindef "u8 -1"

      expect(output.bytesize).to eq(1)
      expect(error.lines.size).to eq(1)
      expect(error.lines.first).to match(/W: -1 in u8 command is negative/)
    end

    it "fails on oversized input" do
      expect do
        bindef "u8 256"
      end.to raise_error(Bindef::CommandError, /width of \d+ exceeds 8 bits/)
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.u8 1 do |f_str|
          expect(f_str).to eq([1].pack("C"))
        end
      end
    end
  end

  describe "#i8" do
    it "emits a int8_t" do
      _, output, _ = bindef <<~INPUT
        i8 1
        i8 0xBB
        i8 0o5
        i8 0b01010101
        i8 -1
      INPUT

      expect(output.bytesize).to eq(5)
      expect(output).to eq([1, 187, 5, 85, -1].pack("ccccc"))
    end

    it "fails on oversized input" do
      expect do
        bindef "i8 1024"
      end.to raise_error(Bindef::CommandError, /width of \d+ exceeds 8 bits/)
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.u8(-10) do |f_str|
          expect(f_str).to eq([-10].pack("c"))
        end
      end
    end
  end

  describe "#u16" do
    it "emits a uint16_t" do
      _, output, _ = bindef "u16 0xFFFF"

      expect(output.bytesize).to eq(2)
      expect(output).to eq([0xFFFF].pack("S"))
    end

    it "obeys the endian pragma" do
      _, output, _ = bindef <<~INPUT
        pragma endian: :little
        u16 0xFF00
        pragma endian: :big
        u16 0xFF00
      INPUT

      expect(output.bytesize).to eq(4)
      expect(output).to eq([0xFF00, 0xFF00].pack("S<S>"))
    end

    it "warns on negative" do
      _, output, error = bindef "u16 -1"

      expect(output.bytesize).to eq(2)
      expect(error.lines.size).to eq(1)
      expect(error.lines.first).to match(/W: -1 in u16 command is negative/)
    end

    it "fails on oversized input" do
      expect do
        bindef "u16 0xFFFFFF"
      end.to raise_error(Bindef::CommandError, /width of \d+ exceeds 16 bits/)
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.u16(1024) do |f_str|
          expect(f_str).to eq([1024].pack("S"))
        end
      end
    end
  end

  describe "#i16" do
    it "emits a int16_t" do
      _, output, _ = bindef "i16 -1024"

      expect(output.bytesize).to eq(2)
      expect(output).to eq([-1024].pack("s"))
    end

    it "obeys the endian pragma" do
      _, output, _ = bindef <<~INPUT
        pragma endian: :little
        i16 0xFF00
        pragma endian: :big
        i16 0xFF00
      INPUT

      expect(output.bytesize).to eq(4)
      expect(output).to eq([0xFF00, 0xFF00].pack("s<s>"))
    end

    it "fails on oversized input" do
      expect do
        bindef "i16 0xFFFFFF"
      end.to raise_error(Bindef::CommandError, /width of \d+ exceeds 16 bits/)
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.i16(-1024) do |f_str|
          expect(f_str).to eq([-1024].pack("s"))
        end
      end
    end
  end

  describe "#u32" do
    it "emits a uint32_t" do
      _, output, _ = bindef "u32 0xFFFFFFFF"

      expect(output.bytesize).to eq(4)
      expect(output).to eq([0xFFFFFFFF].pack("L"))
    end

    it "obeys the endian pragma" do
      _, output, _ = bindef <<~INPUT
        pragma endian: :little
        u32 0x00FF0000
        pragma endian: :big
        u32 0x00FF0000
      INPUT

      expect(output.bytesize).to eq(8)
      expect(output).to eq([0x00FF0000, 0x00FF0000].pack("L<L>"))
    end

    it "warns on negative" do
      _, output, error = bindef "u32 -1"

      expect(output.bytesize).to eq(4)
      expect(error.lines.size).to eq(1)
      expect(error.lines.first).to match(/W: -1 in u32 command is negative/)
    end

    it "fails on oversized input" do
      expect do
        bindef "u32 0xFFFFFFFFFF"
      end.to raise_error(Bindef::CommandError, /width of \d+ exceeds 32 bits/)
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.u32(1024) do |f_str|
          expect(f_str).to eq([1024].pack("L"))
        end
      end
    end
  end

  describe "#i32" do
    it "emits a int32_t" do
      _, output, _ = bindef "i32 -1024"

      expect(output.bytesize).to eq(4)
      expect(output).to eq([-1024].pack("l"))
    end

    it "obeys the endian pragma" do
      _, output, _ = bindef <<~INPUT
        pragma endian: :little
        i32 0x00FF0000
        pragma endian: :big
        i32 0x00FF0000
      INPUT

      expect(output.bytesize).to eq(8)
      expect(output).to eq([0x00FF0000, 0x00FF0000].pack("l<l>"))
    end

    it "fails on oversized input" do
      expect do
        bindef "i32 0xFFFFFFFFFF"
      end.to raise_error(Bindef::CommandError, /width of \d+ exceeds 32 bits/)
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.i32(-1024) do |f_str|
          expect(f_str).to eq([-1024].pack("l"))
        end
      end
    end
  end

  describe "#u64" do
    it "emits a uint64_t" do
      _, output, _ = bindef "u64 0xFFFFFFFFFFFFFFFF"

      expect(output.bytesize).to eq(8)
      expect(output).to eq([0xFFFFFFFFFFFFFFFF].pack("Q"))
    end

    it "obeys the endian pragma" do
      _, output, _ = bindef <<~INPUT
        pragma endian: :little
        u64 0x00FF000000FF0000
        pragma endian: :big
        u64 0x00FF000000FF0000
      INPUT

      expect(output.bytesize).to eq(16)
      expect(output).to eq([0x00FF000000FF0000, 0x00FF000000FF0000].pack("Q<Q>"))
    end

    it "warns on negative" do
      _, output, error = bindef "u64 -1"

      expect(output.bytesize).to eq(8)
      expect(error.lines.size).to eq(1)
      expect(error.lines.first).to match(/W: -1 in u64 command is negative/)
    end

    it "fails on oversized input" do
      expect do
        bindef "u64 0xFFFFFFFFFFFFFFFFFF"
      end.to raise_error(Bindef::CommandError, /width of \d+ exceeds 64 bits/)
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.u64(1024) do |f_str|
          expect(f_str).to eq([1024].pack("Q"))
        end
      end
    end
  end

  describe "#i64" do
    it "emits a int64_t" do
      _, output, _ = bindef "i64 -1024"

      expect(output.bytesize).to eq(8)
      expect(output).to eq([-1024].pack("q"))
    end

    it "obeys the endian pragma" do
      _, output, _ = bindef <<~INPUT
        pragma endian: :little
        i64 0x00FF000000FF0000
        pragma endian: :big
        i64 0x00FF000000FF0000
      INPUT

      expect(output.bytesize).to eq(16)
      expect(output).to eq([0x00FF000000FF0000, 0x00FF000000FF0000].pack("q<q>"))
    end

    it "fails on oversized input" do
      expect do
        bindef "i64 0xFFFFFFFFFFFFFFFFFF"
      end.to raise_error(Bindef::CommandError, /width of \d+ exceeds 64 bits/)
    end

    it "yields the encoded input" do
      bindef do |bd|
        bd.i64(-1024) do |f_str|
          expect(f_str).to eq([-1024].pack("q"))
        end
      end
    end
  end
end
