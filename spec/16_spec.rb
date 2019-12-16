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

    fft = FFT.from_i expected_signals[0]
    expected_signals.each.with_index do |expected_signal, i|
      expect(fft.signal).to eq(expected_signal)
      fft.next!
    end
  end

  it "does a weird number sequence thing with big numbers" do
    expected = {
      80871224585914546619083218645595 => 24176176,
      19617804207202209144916044189917 => 73745418,
      69317163492948606335995924319873 => 52432133
    }

    expected.each do |input, expected_short_signal|
      fft = FFT.from_i input
      100.times { fft.next! }
      expect(fft.short_signal).to eq(expected_short_signal)
    end
  end

  it "cheats and goes backwards if you ask for something ridiculous" do
    expect(FFT.from_i(12345678).lazy_find! 1, 7, 1).to eq(8)
    expect(FFT.from_i(12345678).lazy_find! 4, 5, 2).to eq(49)
    # 12345678
    #      158 1 = 6 + 7 + 8, 5 = 7 + 8, 8 = 8
    #      438
    #      518
    #      498
    #      ^^
  end

  it "does this because you give it really big things to do sometimes" do
    [
      ["03036732577212944063491565474664", 84462026],
      ["02935109699940807407585447034323", 78725270],
      ["03081770884921959731165446850517", 53553731]
    ].each do |test|
      input, expected = test
      fft = FFT.from_repeating_s input
      expect(fft.lazy_find!).to eq(expected)
    end
  end
end
