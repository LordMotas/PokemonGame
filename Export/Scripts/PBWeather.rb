#11045744
begin
  module PBWeather
    SUNNYDAY  = 1
    RAINDANCE = 2
    SANDSTORM = 3
    HAIL      = 4
    #Shadowsky defined elsewhere as 5
    DELTASTREAM   = 6
    PRIMORDIALSEA = 7
    DESOLATELAND  = 8
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end