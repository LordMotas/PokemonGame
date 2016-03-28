begin
  class PokeBattle_ActiveSide
    attr_accessor :effects

    def initialize
      @effects = []
      @effects[PBEffects::LightScreen]      = 0
      @effects[PBEffects::LuckyChant]       = 0
      @effects[PBEffects::Mist]             = 0
      @effects[PBEffects::Reflect]          = 0
      @effects[PBEffects::Safeguard]        = 0
      @effects[PBEffects::Spikes]           = 0
      @effects[PBEffects::StealthRock]      = false
      @effects[PBEffects::Tailwind]         = 0
      @effects[PBEffects::ToxicSpikes]      = 0
      @effects[PBEffects::CraftyShield]     = false
      @effects[PBEffects::QuickGuard]       = false
      @effects[PBEffects::WideGuard]        = false
      @effects[PBEffects::WaterSport]       = 0
      @effects[PBEffects::MudSport]         = 0
      @effects[PBEffects::StickyWeb]        = false
      @effects[PBEffects::LastRoundFainted] = -2
      @effects[PBEffects::FirePledge]        = 0
      @effects[PBEffects::GrassPledge]       = 0
      @effects[PBEffects::WaterPledge]       = 0
    end
  end



  class PokeBattle_ActiveField
    attr_accessor :effects

    def initialize
      @effects = []
      @effects[PBEffects::Gravity]         = 0
      @effects[PBEffects::MagicRoom]       = 0
      @effects[PBEffects::TrickRoom]       = 0
      @effects[PBEffects::WonderRoom]      = 0
      @effects[PBEffects::ElectricTerrain] = 0
      @effects[PBEffects::GrassyTerrain]   = 0
      @effects[PBEffects::MistyTerrain]    = 0
      @effects[PBEffects::IonDeluge]       = false
    end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end