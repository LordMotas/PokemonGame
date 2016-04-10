begin
  module PBEffects
    # These effects apply to a battler
    AquaRing          = 0
    AquaRing          = 0
    Attract           = 1
    Bide              = 2
    BideDamage        = 3
    BideTarget        = 4
    Charge            = 5
    ChoiceBand        = 6
    Confusion         = 7
    Counter           = 8
    CounterTarget     = 9
    Curse             = 10
    DefenseCurl       = 11
    DestinyBond       = 12
    Disable           = 13
    DisableMove       = 14
    EchoedVoice       = 15
    Embargo           = 16
    Encore            = 17
    EncoreIndex       = 18
    EncoreMove        = 19
    Endure            = 20
    FlashFire         = 21
    Flinch            = 22
    FocusEnergy       = 23
    FollowMe          = 24
    Foresight         = 25
    FuryCutter        = 26
    FutureSight       = 27
    FutureSightDamage = 28
    FutureSightMove   = 29
    FutureSightUser   = 30
    GastroAcid        = 31
    Grudge            = 32
    HealBlock         = 33
    HealingWish       = 34
    HelpingHand       = 35
    HyperBeam         = 36
    Imprison          = 37
    Ingrain           = 38
    LeechSeed         = 39
    LockOn            = 40
    LockOnPos         = 41
    LunarDance        = 42
    MagicCoat         = 43
    MagnetRise        = 44
    MeanLook          = 45
    Metronome         = 46
    Minimize          = 47
    MiracleEye        = 48
    MirrorCoat        = 49
    MirrorCoatTarget  = 50
    MultiTurn         = 51 # Trapping move
    MultiTurnAttack   = 52
    MultiTurnUser     = 53
    Nightmare         = 54
    Outrage           = 55
    PerishSong        = 56
    PerishSongUser    = 57
    Pinch             = 58 # Battle Palace only
    PowerTrick        = 59
    Protect           = 60
    ProtectNegation   = 61
    ProtectRate       = 62
    Pursuit           = 63
    Rage              = 64
    Revenge           = 65
    Rollout           = 66
    Roost             = 67
    SkyDrop           = 68
    SmackDown         = 69
    Snatch            = 70
    Stockpile         = 71
    StockpileDef      = 72
    StockpileSpDef    = 73
    Substitute        = 74
    Taunt             = 75
    Telekinesis       = 76
    Torment           = 77
    Toxic             = 78
    Trace             = 79
    Transform         = 80
    Truant            = 81
    TwoTurnAttack     = 82
    Uproar            = 83
    WeightMultiplier  = 84
    Wish              = 85
    WishAmount        = 86
    WishMaker         = 87
    Yawn              = 88
    Illusion          = 89
    KingsShield       = 90
    ParentalBondHit   = 91 
    ItemLost          = 92
    CanBelch          = 93
    Electrify         = 94
    FinalGambit       = 95
    SpikyShield       = 96
    Quash             = 97
    ForceMove         = 98 # Round, After You, etc
    ForceSwitch       = 99 # Dragon Tail, etc
    LetSwitch         = 100 # Volt Switch, etc
    MeFirst           = 101
    MatBlock          = 102
    Powder            = 103
    # These effects apply to a side
    LightScreen       = 0
    LuckyChant        = 1
    Mist              = 2
    Reflect           = 3
    Safeguard         = 4
    Spikes            = 5
    StealthRock       = 6
    Tailwind          = 7
    ToxicSpikes       = 8
    CraftyShield      = 9
    QuickGuard        = 10
    WideGuard         = 11
    WaterSport        = 12
    MudSport          = 13
    StickyWeb         = 14
    LastRoundFainted  = 15
    FirePledge        = 16
    GrassPledge       = 17
    WaterPledge       = 18
    # These effects apply to the battle (i.e. both sides)
    Gravity         = 0
    MagicRoom       = 1
    TrickRoom       = 2
    WonderRoom      = 3
    ElectricTerrain = 4
    GrassyTerrain   = 5
    MistyTerrain    = 6
    IonDeluge       = 7
    # These effects apply to the usage of a move
    SpecialUsage = 0
    PassedTrying = 1
    TotalDamage  = 2
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end