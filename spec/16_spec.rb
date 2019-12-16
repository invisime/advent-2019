require_relative '../16'

RSpec.describe FFT do
  it "knows how to multiply the pattern out" do
    expect(FFT.pattern_for 1).to match_array([1, 0, -1, 0])
    expect(FFT.pattern_for 2).to match_array([0, 1, 1, 0, 0, -1, -1, 0])
    expect(FFT.pattern_for 3).to match_array([0, 0, 1, 1, 1, 0, 0, 0, -1, -1, -1, 0])
  end

  it "does a weird number sequence thing" do
    expected_signals = [
      12345678,
      48226158,
      34040438,
      3415518,
      1029498
    ]

    fft = FFT.new expected_signals[0]
    expected_signals.each.with_index do |expected_signal, i|
      expect(fft.phase).to eq(i)
      expect(fft.signal).to eq(expected_signal)
      expect(fft.magnitude).to eq(8)
      fft = fft.next
    end
  end

  it "does a weird number sequence thing with big numbers" do
    expected = {
      80871224585914546619083218645595 => 24176176,
      19617804207202209144916044189917 => 73745418,
      69317163492948606335995924319873 => 52432133
    }

    expected.each do |input, expected_short_signal|
      fft = FFT.new input
      100.times { fft = fft.next }
      expect(fft.phase).to eq(100)
      expect(fft.short_signal).to eq(expected_short_signal)
    end
  end
end
