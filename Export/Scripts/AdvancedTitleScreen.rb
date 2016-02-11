#===============================================================================
#  New animated Title Screens for Pokemon Essentials
#    by Luka S.J.
#
#  Adds new visual styles to the Pokemon Essentials title screen, and animates
#  depending on the style selected
#
#  A lot of time and effort went into making this an extensive and comprehensive
#  resource. So please be kind enough to give credit when using it.
#===============================================================================
# Config value for selecting title screen style
SCREENSTYLE = 5
# 1 - FR/LG
# 2 - HG/SS
# 3 - R/S/E
# 4 - D/P/PT
# 5 - B/W
# 6 - X/Y    <- Definitely the best one

# Species for cry bein played
SPECIES = PBSpecies::PIKACHU

# BGM names for the different styles
GEN_ONE_BGM = "title_frlg.ogg"
GEN_TWO_BGM = "title_hgss.ogg"
GEN_THREE_BGM = "title_rse.ogg"
GEN_FOUR_BGM = "dppt opening"
GEN_FIVE_BGM = "title_bw.ogg"
GEN_SIX_BGM = "title_xy.ogg"

# Turns on the option for the game to restart after music has done playing
RESTART_TITLE = true

# Decides whether or not to play the title screen even if $DEBUG is on
PLAY_ON_DEBUG = false
#-------------------------------------------------------------------------------
# The Following only applies if you're using the Gen 6 style + Elite Battle.
# Species of the Pokemon displayed in the demo 
EB_SPECIES = [PBSpecies::CHARMELEON,PBSpecies::IVYSAUR,PBSpecies::WARTORTLE]
# Battle backgrounds for different species
EB_BG = ["City","Field","Water"]
# Battle bases for different species
EB_BASE = ["Cave","FieldDirt","CityConcrete"]
#-------------------------------------------------------------------------------
# The following only applies to people wanting to use the title screens in a
# DS styled game.
# There is no need to change any of the following values if you're using
# either Venom12's or KleinStudio's kits.
#
# Change this number to the height of a single screen
VIEWPORT_HEIGHT = DEFAULTSCREENHEIGHT
# Takes into account the separating bar for DS screens. Change this to the y 
# separation of the two screens (usually 16).
VIEWPORT_OFFSET = 0
#-------------------------------------------------------------------------------
class Scene_Intro
  
  alias main_old main
  def main
    $DEBUG = $memDebug
    Graphics.transition(0)
    # Loads up a species cry for the title screen
    @cry = pbCryFile(SPECIES)
    # Cycles through the intro pictures
    @skip = false
    self.cyclePics(@pics)
    # Selects title screen style
    case SCREENSTYLE
    when 1
      @screen = GenOneStyle.new
    when 2
      @screen = GenTwoStyle.new
    when 3
      @screen = GenThreeStyle.new
    when 4
      @screen = GenFourStyle.new
    when 5
      @screen = GenFiveStyle.new
    when 6
      @screen = GenSixStyle.new
    else
      @screen = EssentialsTitleScreen.new # For compatibility sake if SCREENSTYLE is wrong value
    end
    # Plays the title screen intro (is skippable)
    @screen.intro
    # Creates/updates the main title screen loop
    self.update
    Graphics.freeze
  end
  
  def update
    ret=0
    loop do
      @screen.update
      Graphics.update
      Input.update
      if Input.press?(Input::DOWN) &&
        Input.press?(Input::B) &&
        Input.press?(Input::CTRL)
        ret=1
        break
      end
      if Input.trigger?(Input::C)
        ret=2
        break
      end
    end
    case ret
    when 1
      closeSplashDelete(scene,args)
    when 2
      closeTitle 
    end
  end
  
  def closeTitle
    # Play Pokemon cry
    pbSEPlay(@cry,100,100) if @cry && SCREENSTYLE!=6
    # Fade out
    pbBGMStop(1.0)
    # disposes current title screen
    disposeTitle
    # initializes load screen
    sscene=PokemonLoadScene.new
    sscreen=PokemonLoad.new(sscene)
    sscreen.pbStartLoadScreen
  end
  
  def closeTitleDelete
    pbBGMStop(1.0)
    # disposes current title screen
    disposeTitle
    # initializes delete screen
    sscene=PokemonLoadScene.new
    sscreen=PokemonLoad.new(sscene)
    sscreen.pbStartDeleteScreen
  end
  
  def cyclePics(pics)
    sprite=Sprite.new
    sprite.opacity=0
    for i in 0...pics.length
      bitmap=pbBitmap("Graphics/Titles/#{pics[i]}")
      sprite.bitmap=bitmap
      15.times do
        sprite.opacity+=17
        pbWait(1)
      end
      wait(32)
      15.times do
        sprite.opacity-=17
        pbWait(1)
      end
    end
    sprite.dispose
  end
  
  def disposeTitle
    @screen.dispose
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
end
#===============================================================================
# Styled to look like the FRLG games
#===============================================================================
class GenOneStyle
  def safe?(path)
    ext = getTSExtension
    if FileTest.exist?(path+ext+".png")
      return path+ext
    else
      return path
    end
  end
  
  def initialize
    # sound file for playing the title screen BGM
    bgm = GEN_ONE_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    # speed of the effect movement
    @speed = 16
    @opacity = 17
    @disposed = false
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate
    pbBGMPlay(bgm)
    pbWait(10) if @mp3
    
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    @sprites = {}
    
    @sprites["bars"] = Sprite.new(@viewport)
    @sprites["bars"].bitmap = pbBitmap("Graphics/Titles/gen1_bars")
    @sprites["bars"].x = @viewport.rect.width
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/Titles/gen1_bg")
    @sprites["bg"].x = -@viewport.rect.width
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x = 138
    @sprites["start"].y = 314
    @sprites["start"].opacity = 0
    @sprites["effect"] = AnimatedPlane.new(@viewport)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen1_effect")
    @sprites["effect"].visible = false
    @sprites["poke"] = Sprite.new(@viewport)
    @sprites["poke"].bitmap = pbBitmap("Graphics/Titles/gen1_poke")
    @sprites["poke"].tone = Tone.new(0,0,0,255)
    @sprites["poke"].opacity = 0
    @sprites["poke2"] = Sprite.new(@viewport)
    @sprites["poke2"].bitmap = pbBitmap("Graphics/Titles/gen1_poke")
    @sprites["poke2"].tone = Tone.new(255,255,255,255)
    @sprites["poke2"].src_rect.set(0,@viewport.rect.height,@viewport.rect.width,48)
    @sprites["poke2"].y = @viewport.rect.height
    @sprites["logo"] = Sprite.new(@viewport)
    bitmap1=pbBitmap(safe?("Graphics/Titles/pokelogo"))
    bitmap2=pbBitmap(safe?("Graphics/Titles/pokelogo2"))
    @sprites["logo"].bitmap = Bitmap.new(bitmap1.width,bitmap1.height)
    @sprites["logo"].bitmap.blt(0,0,bitmap2,Rect.new(0,0,bitmap2.width,bitmap2.height))
    @sprites["logo"].bitmap.blt(0,0,bitmap1,Rect.new(0,0,bitmap1.width,bitmap1.height))
    @sprites["logo"].tone = Tone.new(255,255,255,255)
    @sprites["logo"].x = 8
    @sprites["logo"].y = 24
    @sprites["logo"].opacity = 0
    
  end
  
  def intro
    wait(16)
    16.times do
      @sprites["poke2"].src_rect.y-=24
      @sprites["poke2"].y-=24
      wait(1)
    end
    @sprites["poke2"].opacity=0
    @sprites["poke2"].src_rect.set(0,0,@viewport.rect.width,@viewport.rect.height)
    @sprites["poke2"].y=0
    wait(32)
    64.times do
      @sprites["poke"].opacity+=4
      wait(1)
    end
    @sprites["poke2"].opacity=255
    8.times do
      @sprites["poke2"].opacity-=51
      @sprites["bg"].x+=64
      wait(1)
    end
    wait(8)
    @sprites["poke2"].opacity=255
    8.times do
      @sprites["poke2"].opacity-=51
      @sprites["bars"].x-=64
      wait(1)
    end
    wait(8)
    @sprites["logo"].opacity=255
    @sprites["poke2"].opacity=255
    @sprites["poke"].tone=Tone.new(0,0,0,0)
    @sprites["effect"].visible=true
    c=255.0
    16.times do
      @sprites["poke2"].opacity-=255.0/16
      c-=255.0/16
      @sprites["logo"].tone=Tone.new(c,c,c)
      @sprites["effect"].ox+=@speed
      wait(1)
    end
    @skip = false
  end
  
  def update
    @currentFrame+=1 if !@skip
    @sprites["effect"].ox+=@speed
    @sprites["start"].opacity+=@opacity
    @opacity=-17 if @sprites["start"].opacity>=255
    @opacity=+17 if @sprites["start"].opacity<=0
    
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
  end
  
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      self.update
      wait(1)
    end
    raise Reset.new
  end
  
  def dispose
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the HGSS games
#===============================================================================
class GenTwoStyle
  def safe?(path)
    ext = getTSExtension
    if FileTest.exist?(path+ext+".png")
      return path+ext
    else
      return path
    end
  end
  
  def initialize
    # sound file for playing the title screen BGM
    bgm = GEN_TWO_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    # speed of the effect movement
    @speed = 2
    @frame = 0
    @opacity = 17
    @particles = 16
    @effo = 1
    @disposed = false
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate - 40
    pbBGMPlay(bgm)
    pbWait(10) if @mp3
    
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    @viewport.tone = Tone.new(-255,-255,-255)
    y = DS_STYLE ? VIEWPORT_OFFSET+VIEWPORT_HEIGHT : 0
    @viewport2 = Viewport.new(0,y,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2.z = 99998
    @sprites = {}
    @viewport2.tone = Tone.new(-255,-255,-255) if DS_STYLE
    
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg2"] = Sprite.new(@viewport2)
    if DS_STYLE
      @sprites["bg"].bitmap = pbBitmap("Graphics/Titles/gen_2_bg")
      @sprites["bg2"].bitmap = pbBitmap("Graphics/Titles/gen_2_bg2")
    else
      @sprites["bg2"].bitmap = pbBitmap("Graphics/Titles/gen_2_bg")
    end
    
    @sprites["effect2"] = AnimatedPlane.new(@viewport2)
    @sprites["effect2"].bitmap = pbBitmap("Graphics/Titles/gen_2_effect2")
    
    @sprites["effect"] = Sprite.new(@viewport)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen_2_effect")
    @sprites["effect"].ox = @sprites["effect"].bitmap.width/2
    @sprites["effect"].oy = @sprites["effect"].bitmap.height/2
    @sprites["effect"].x = @viewport.rect.width*0.75
    @sprites["effect"].y = @viewport.rect.height/2
    @sprites["effect3"] = Sprite.new(@viewport)
    @sprites["effect3"].bitmap = pbBitmap("Graphics/Titles/gen_2_effect3")
    @sprites["effect3"].ox = @sprites["effect3"].bitmap.width/2
    @sprites["effect3"].oy = @sprites["effect3"].bitmap.height/2
    @sprites["effect3"].x = @sprites["effect"].x
    @sprites["effect3"].y = @sprites["effect"].y
    @sprites["effect3"].opacity = 0
    
    view = DS_STYLE ? @viewport2 : @viewport
    @sprites["particle"] = Sprite.new(view)
    @sprites["particle"].bitmap = pbBitmap("Graphics/Titles/gen_2_particle")
    @sprites["particle"].src_rect.set(0,0,@sprites["particle"].bitmap.width/2,@sprites["particle"].bitmap.height)
    @sprites["particle"].oy = @sprites["particle"].bitmap.height/2
    @sprites["particle"].x = view.rect.width/2
    @sprites["particle"].y = view.rect.height/2 + 20
    @sprites["particle"].y+=64 if !DS_STYLE
    @sprites["particle"].visible = false
    
    @sprites["pokemon"] = Sprite.new(view)
    @sprites["pokemon"].bitmap = pbBitmap("Graphics/Titles/gen_2_pokemon")
    @sprites["pokemon"].src_rect.set(0,0,@sprites["pokemon"].bitmap.height,@sprites["pokemon"].bitmap.height)
    @sprites["pokemon"].ox = @sprites["pokemon"].src_rect.width/2
    @sprites["pokemon"].oy = @sprites["pokemon"].src_rect.height/2
    @sprites["pokemon"].x = view.rect.width/2
    @sprites["pokemon"].y = view.rect.height/2
    @sprites["pokemon"].y+=64 if !DS_STYLE
    @sprites["pokemon"].visible = false
    
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].ox = @sprites["start"].bitmap.width/2
    @sprites["start"].x = @viewport2.rect.width/2
    @sprites["start"].y = @viewport2.rect.height-32
    @sprites["start"].z = 10
    @sprites["start"].opacity = 0
    @sprites["start"].visible = false
    
    @sprites["logo"] = Sprite.new(@viewport)
    bitmap1=pbBitmap(safe?("Graphics/Titles/pokelogo"))
    bitmap2=pbBitmap(safe?("Graphics/Titles/pokelogo2"))
    @sprites["logo"].bitmap = Bitmap.new(bitmap1.width,bitmap1.height)
    @sprites["logo"].bitmap.blt(0,0,bitmap2,Rect.new(0,0,bitmap2.width,bitmap2.height))
    @sprites["logo"].bitmap.blt(0,0,bitmap1,Rect.new(0,0,bitmap1.width,bitmap1.height))
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/2
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = @viewport.rect.width/2
    @sprites["logo"].y = @viewport.rect.height/2
    @sprites["logo"].z = 10
    @sprites["logo"].opacity = 0
    
    if !DS_STYLE
      @sprites["logo"].y-=58
      @sprites["effect"].y-=58
      @sprites["effect3"].y-=58
    end
    
  end
  
  def intro
    @logolock = true
    10.times do
      @viewport.tone.red+=25.5
      @viewport.tone.green+=25.5
      @viewport.tone.blue+=25.5
      if DS_STYLE
        @viewport2.tone.red+=25.5
        @viewport2.tone.green+=25.5
        @viewport2.tone.blue+=25.5
      end
      self.update
      wait(1,false)
    end
    22.times do
      self.update
      wait(1,false)
    end
    @sprites["logo"].y+=64
    64.times do
      @sprites["logo"].y-=1
      @sprites["logo"].opacity+=4
      @sprites["logo"].tone.red+=2
      @sprites["logo"].tone.green+=2
      @sprites["logo"].tone.blue+=2
      self.update
      wait(1,false)
    end
    16.times do
      @sprites["logo"].tone.red+=8
      @sprites["logo"].tone.green+=8
      @sprites["logo"].tone.blue+=8
      self.update
      wait(1,false)
    end
    @sprites["start"].opacity = 0
    @sprites["start"].visible = true
    @opacity = 17
    @viewport.tone = Tone.new(255,255,255)
    @viewport2.tone = Tone.new(255,255,255) if DS_STYLE
    @logolock = false
    for i in 0...@particles
      @sprites["p#{i}"] = AnimatedSpriteParticle.new(@viewport)
      @sprites["p#{i}"].dx = @sprites["effect"].x
      @sprites["p#{i}"].dy = @sprites["effect"].y
      @sprites["p#{i}"].inverted = false
      @sprites["p#{i}"].repeat = 1
      @sprites["p#{i}"].count = 0
      @sprites["p#{i}"].refresh
    end
    @sprites["pokemon"].visible = true
    @sprites["particle"].visible = true
    17.times do
      @viewport.tone.red-=15 if @viewport.tone.red > 0
      @viewport.tone.green-=15 if @viewport.tone.green > 0
      @viewport.tone.blue-=15 if @viewport.tone.blue > 0
      if DS_STYLE
        @viewport2.tone.red-=15 if @viewport2.tone.red > 0
        @viewport2.tone.green-=15 if @viewport2.tone.green > 0
        @viewport2.tone.blue-=15 if @viewport2.tone.blue > 0
      end
      self.update
      wait(1,false)
    end
  end
  
  def update
    @currentFrame+=1 if !@skip
    @frame+=1
    if !@logolock
      @sprites["logo"].tone.red-=15 if @sprites["logo"].tone.red > 0
      @sprites["logo"].tone.green-=15 if @sprites["logo"].tone.green > 0
      @sprites["logo"].tone.blue-=15 if @sprites["logo"].tone.blue > 0
    end
    @sprites["pokemon"].src_rect.x+=@sprites["pokemon"].src_rect.width if @frame > @speed
    @sprites["pokemon"].src_rect.x=0 if @sprites["pokemon"].src_rect.x >= @sprites["pokemon"].bitmap.width
    @sprites["particle"].src_rect.x-=16
    @sprites["particle"].src_rect.x=@sprites["particle"].bitmap.width/2 if @sprites["particle"].src_rect.x <= 0
    @frame = 0 if @frame > @speed
    @sprites["start"].opacity+=@opacity
    @sprites["effect"].angle+=0.4 if $ResizeFactor <= 1
    @sprites["effect2"].ox-=1
    @sprites["effect3"].angle+=0.2 if $ResizeFactor <= 1
    @sprites["effect3"].opacity-=@effo
    if @sprites["effect3"].opacity <= 0
      @effo = -1
    elsif @sprites["effect3"].opacity >= 255
      @effo = 1
    end
    @opacity=-17 if @sprites["start"].opacity>=255
    @opacity=+17 if @sprites["start"].opacity<=0
    for i in 0...@particles
      @sprites["p#{i}"].update if @sprites["p#{i}"]
    end
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
  end
  
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      @viewport2.tone.red-=5
      @viewport2.tone.green-=5
      @viewport2.tone.blue-=5
      self.update
      wait(1)
    end
    raise Reset.new
  end
  
  def dispose
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the RSE games
#===============================================================================
class GenThreeStyle
  def safe?(path)
    ext = getTSExtension
    if FileTest.exist?(path+ext+".png")
      return path+ext
    else
      return path
    end
  end
  
  def initialize
    # sound file for playing the title screen BGM
    bgm = GEN_THREE_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    # speed of the effect movement
    @speed = 1
    @opacity = 2
    @frame = 0
    @disposed = false
    # decides whether to use the OR/AS or R/S/E transitioning
    @new = true
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate
    pbBGMPlay(bgm)
    
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    y = DS_STYLE ? VIEWPORT_OFFSET+VIEWPORT_HEIGHT : 0
    @viewport2 = Viewport.new(0,y,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2.z = 99998
    @sprites = {}
    
    @sprites["bg"] = Sprite.new(@viewport2)
    @sprites["bg"].bitmap = pbBitmap("Graphics/Titles/gen3_bg")
    @sprites["bg"].tone = Tone.new(255,255,255)
    @sprites["bg"].opacity = 0
    @sprites["bg2"] = Sprite.new(@viewport)
    @sprites["bg2"].bitmap = pbBitmap("Graphics/Titles/gen3_bg_ds1") if DS_STYLE || @new
    @sprites["bg2"].opacity = 0
    @sprites["poke1"] = Sprite.new(@viewport2)
    @sprites["poke1"].bitmap=pbBitmap("Graphics/Titles/gen3_poke1")
    @sprites["poke1"].opacity = 0
    @sprites["poke2"] = Sprite.new(@viewport2)
    @sprites["poke2"].bitmap=pbBitmap("Graphics/Titles/gen3_poke2")
    @sprites["poke2"].opacity=0
    @sprites["effect"] = AnimatedPlane.new(@viewport2)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen3_effect")
    @sprites["effect"].visible = false
    @sprites["logo2"] = Sprite.new(@viewport)
    @sprites["logo2"].bitmap = pbBitmap(safe?("Graphics/Titles/pokelogo2"))
    @sprites["logo2"].x = 50
    @sprites["logo2"].y = 24-32
    @sprites["logo2"].opacity = 0
    @sprites["logo2"].z = 5 if DS_STYLE
    @sprites["logo1"] = Sprite.new(@viewport)
    @sprites["logo1"].bitmap = pbBitmap(safe?("Graphics/Titles/pokelogo"))
    @sprites["logo1"].x = 50
    @sprites["logo1"].y = 24+64
    @sprites["logo1"].opacity=0
    @sprites["logo3"] = Sprite.new(@viewport)
    @sprites["logo3"].bitmap = pbBitmap(safe?("Graphics/Titles/pokelogo"))
    @sprites["logo3"].tone = Tone.new(255,255,255)
    @sprites["logo3"].x = 18
    @sprites["logo3"].y = 24+64
    @sprites["logo3"].src_rect.set(-34,0,34,230)
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x = 178
    @sprites["start"].y = 312
    @sprites["start"].y+=32 if DS_STYLE
    @sprites["start"].visible = false
  end
  
  def intro
    if DS_STYLE || @new
      @sprites["logo1"].src_rect.width = 0
      @sprites["logo1"].opacity = 255
    end
    16.times do
      if DS_STYLE || @new
        @sprites["logo1"].src_rect.width+=(@sprites["logo1"].bitmap.width/16.0).ceil
      else
        @sprites["logo1"].opacity+=16
      end
      wait(1)
    end
    wait(16)
    12.times do
      if !(DS_STYLE || @new)
        @sprites["logo3"].x+=34
        @sprites["logo3"].src_rect.x+=34
      end
      wait(1)
    end
    @sprites["logo3"].x=18
    @sprites["logo3"].src_rect.x=-34
    wait(32)
    2.times do
      12.times do
        @sprites["logo3"].x+=34
        @sprites["logo3"].src_rect.x+=34
        @sprites["bg"].opacity+=21.5 if !(DS_STYLE || @new)
        @sprites["bg2"].opacity+=1 if DS_STYLE || @new
        wait(1)
      end
      @sprites["logo3"].x=18
      @sprites["logo3"].src_rect.x=-34
      4.times do
        @sprites["bg2"].opacity+=1 if DS_STYLE || @new
        wait(1)
      end
      16.times do
        @sprites["bg"].opacity-=16 if !(DS_STYLE || @new)
        @sprites["bg2"].opacity+=1 if DS_STYLE || @new
        wait(1)
      end
      32.times do
        @sprites["bg2"].opacity+=1 if DS_STYLE || @new
        wait(1)
      end
    end
    @sprites["logo3"].visible=false
    if DS_STYLE || @new
      @sprites["logo2"].ox = @sprites["logo2"].bitmap.width/2
      @sprites["logo2"].oy = @sprites["logo2"].bitmap.height/2
      @sprites["logo2"].x = @viewport.rect.width/2
      @sprites["logo2"].y+=96+@sprites["logo2"].bitmap.height/2
      @sprites["logo2"].zoom_x = 1.4
      @sprites["logo2"].zoom_y = 1.4
      @sprites["logo2"].opacity = 0
      @sprites["logo2"].tone = Tone.new(255,255,255)
    end
    16.times do
      if DS_STYLE || @new
        @sprites["logo1"].tone.red+=3
        @sprites["logo1"].tone.green+=3
        @sprites["logo1"].tone.blue+=3
      else
        @sprites["logo1"].y-=2
      end
      @sprites["bg2"].opacity+=1 if DS_STYLE || @new
      wait(1)
    end
    16.times do
      if DS_STYLE || @new
        @sprites["logo1"].tone.red+=3
        @sprites["logo1"].tone.green+=3
        @sprites["logo1"].tone.blue+=3
      else
        @sprites["logo1"].y-=2
        @sprites["logo2"].y+=2
        @sprites["logo2"].opacity+=16
      end
      @sprites["bg2"].opacity+=1 if DS_STYLE || @new
      wait(1)
    end
    43.times do
      if DS_STYLE || @new
        @sprites["logo1"].tone.red+=3
        @sprites["logo1"].tone.green+=3
        @sprites["logo1"].tone.blue+=3
        @sprites["bg2"].tone.red+=3
        @sprites["bg2"].tone.green+=3
        @sprites["bg2"].tone.blue+=3
      end
      @sprites["bg2"].opacity+=1 if DS_STYLE || @new
      wait(1)
    end
    8.times do
      if DS_STYLE || @new
        @sprites["logo1"].tone.red+=3
        @sprites["logo1"].tone.green+=3
        @sprites["logo1"].tone.blue+=3
        @sprites["logo2"].opacity+=36
        @sprites["logo2"].zoom_x-=0.05
        @sprites["logo2"].zoom_y-=0.05
        @sprites["bg2"].tone.red+=3
        @sprites["bg2"].tone.green+=3
        @sprites["bg2"].tone.blue+=3
      end
      wait(1)
    end
    if DS_STYLE || @new
      @viewport.tone = Tone.new(255,255,255)
      @viewport2.tone = Tone.new(255,255,255)
      @sprites["bg2"].bitmap = pbBitmap("Graphics/Titles/gen3_bg_ds2")
      if !DS_STYLE
       @sprites["logo1"].y-=64
       @sprites["logo2"].y-=64
       @sprites["bg2"].visible = false
      end
    end
    wait(5)
    @sprites["logo1"].tone = Tone.new(0,0,0)
    @sprites["logo2"].tone = Tone.new(0,0,0)
    @sprites["bg"].tone=Tone.new(0,0,0)
    @sprites["bg"].opacity=255
    @sprites["bg2"].tone = Tone.new(0,0,0)
    @sprites["bg2"].opacity = 255
    @sprites["poke1"].opacity=255
    @sprites["effect"].visible=true
    @skip = false
  end
  
  def update
    @currentFrame+=1 if !@skip
    @frame+=1
    @viewport.tone.red-=15 if @viewport.tone.red > 0
    @viewport.tone.green-=15 if @viewport.tone.green > 0
    @viewport.tone.blue-=15 if @viewport.tone.blue > 0
    @viewport2.tone.red-=15 if @viewport.tone.red > 0
    @viewport2.tone.green-=15 if @viewport.tone.green > 0
    @viewport2.tone.blue-=15 if @viewport.tone.blue > 0
    @sprites["effect"].oy+=@speed
    @sprites["poke2"].opacity+=@opacity
    @opacity=-2 if @sprites["poke2"].opacity>=255
    @opacity=+2 if @sprites["poke2"].opacity<=0
    if @frame==8
      @sprites["start"].visible=true
    elsif @frame==24
      @sprites["start"].visible=false
      @frame=0
    end
      
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
  end
  
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      @viewport2.tone.red-=5
      @viewport2.tone.green-=5
      @viewport2.tone.blue-=5
      self.update
      wait(1)
    end
    raise Reset.new
  end
  
  def dispose
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the DPPT games
#===============================================================================
class GenFourStyle
  def safe?(path)
    ext = getTSExtension
    if FileTest.exist?(path+ext+".png")
      return path+ext
    else
      return path
    end
  end
  
  def initialize
    # sound file for playing the title screen BGM
    bgm = GEN_FOUR_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    # speed of the silhouette animation
    @speed = 3
    @sframe = 0
    @opacity = 17
    @disposed = false
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate
    pbBGMPlay(bgm)
    
    # creates all the necessary graphics
    y = DS_STYLE ? VIEWPORT_OFFSET+VIEWPORT_HEIGHT : 0
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    @viewport2 = Viewport.new(0,y,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2.z = 99998
    @sprites = {}
    
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = pbBitmap("Graphics/Titles/gen_4_bg_ds") if DS_STYLE
    @sprites["background"].opacity = 0
    
    @sprites["effect"] = Sprite.new(@viewport2)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen_4_eff")
    @sprites["effect"].y = @viewport.rect.height
    @sprites["effect"].opacity = 0
    
    @sprites["sil"] = Sprite.new(@viewport2)
    @sprites["sil"].bitmap = pbBitmap("Graphics/Titles/gen_4_sil")
    @sprites["sil"].src_rect.set(0,0,@viewport.rect.width,@viewport.rect.height)
    @sprites["sil"].opacity = 0
    
    @sprites["overlay"] = Sprite.new(@viewport2)
    @sprites["overlay"].bitmap = pbBitmap("Graphics/Titles/gen_4_over")
    @sprites["overlay"].z = 20
    @sprites["overlay"].opacity = 0
    
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x = (@viewport.rect.width-@sprites["start"].bitmap.width)/2
    @sprites["start"].y = @viewport.rect.height - 32
    @sprites["start"].opacity = 0
    @sprites["start"].z = 45
    
    @sprites["logo"] = Sprite.new(@viewport)
    bitmap1=pbBitmap(safe?("Graphics/Titles/pokelogo"))
    bitmap2=pbBitmap(safe?("Graphics/Titles/pokelogo2"))
    @sprites["logo"].bitmap = Bitmap.new(bitmap1.width,bitmap1.height)
    @sprites["logo"].bitmap.blt(0,0,bitmap2,Rect.new(0,0,bitmap2.width,bitmap2.height))
    @sprites["logo"].bitmap.blt(0,0,bitmap1,Rect.new(0,0,bitmap1.width,bitmap1.height))
    @sprites["logo"].tone = Tone.new(0,0,0,255)
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/2
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = @viewport.rect.width/2 - 4
    y = DS_STYLE ? -20  : 30
    @sprites["logo"].y = @viewport.rect.height/2 - y
    @sprites["logo"].z = 50
    @sprites["logo"].opacity = 0
    
  end
  
  def intro
    for i in 0...80
      @sprites["logo"].opacity+=3.2
      @sprites["overlay"].opacity+=3.2 if !DS_STYLE
      @sprites["logo"].y-=1 if i%4==0
      wait(1)
    end
    c = 255
    @viewport.tone = Tone.new(c,c,c)
    @viewport2.tone = Tone.new(c,c,c)
    @sprites["logo"].tone = Tone.new(0,0,0)
    @sprites["overlay"].opacity = 255
    @sprites["background"].opacity = 255
    @sprites["effect"].opacity = 255
    @sprites["sil"].opacity = 255
    17.times do
      c-=15
      @viewport.tone = Tone.new(c,c,c)
      @viewport2.tone = Tone.new(c,c,c)
      self.update
      wait(1)
    end
    @skip = false
  end
  
  def update
    @currentFrame+=1 if !@skip
    @sframe+=1
    if @sframe > @speed
      @sprites["sil"].src_rect.x+=@viewport.rect.width
      @sprites["sil"].src_rect.x=0 if @sprites["sil"].src_rect.x>=@sprites["sil"].bitmap.width
      @sframe=0
    end
    @sprites["start"].opacity+=@opacity
    @opacity=-17 if @sprites["start"].opacity>=255
    @opacity=+17 if @sprites["start"].opacity<=0
    @sprites["effect"].y-=16
    @sprites["effect"].y = @viewport.rect.height if @sprites["effect"].y<-(@viewport.rect.height*12)
    
    if @currentFrame==@totalFrames
      #self.restart if RESTART_TITLE
    end
  end
  
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      @viewport2.tone.red-=5
      @viewport2.tone.green-=5
      @viewport2.tone.blue-=5
      self.update
      wait(1)
    end
    raise Reset.new
  end
  
  def dispose
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the BW games
#===============================================================================
class GenFiveStyle
  
  def safe?(path)
    ext = getTSExtension
    if FileTest.exist?(path+ext+".png")
      return path+ext
    else
      return path
    end
  end
  
  def getAvgColor(bitmap,width,height)
    red = 0
    green = 0
    blue = 0
    n = 0
    for x in 0...width
      for y in 0...height
        c = bitmap.get_pixel(x,y)
        red+=c.red
        green+=c.green
        blue+=c.blue
        n+=1
      end
    end
    return Color.new((red/n)+60,(green/n)+60,(blue/n)+60)
  end
  
  def initialize
    # resolves issues with Pokemon with multiple forms
    $Trainer = PokeBattle_Trainer.new("",0)
    # coloures background according to the SPECIES sprite
    pokemon = PokeBattle_Pokemon.new(SPECIES,5)                               
    # pokemon.form = 1                                                          
    bmp = pbLoadPokemonBitmap(pokemon).bitmap                                 
    color = self.getAvgColor(bmp,bmp.width,bmp.height)
    # sound file for playing the title screen BGM
    bgm = GEN_FIVE_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    # speed of the silhouette animation
    @speed = 3
    @sframe = 0
    @lframe = 0
    @opacity = 17
    @disposed = false
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate - 40
    pbBGMPlay(bgm)
    
    # creates all the necessary graphics
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport.z = 99999
    y = DS_STYLE ? VIEWPORT_OFFSET+VIEWPORT_HEIGHT : 0
    @viewport2 = Viewport.new(0,y,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2.z = 99998
    @sprites = {}
    
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = pbBitmap("Graphics/Titles/gen_5_bg_ds") if DS_STYLE
    @sprites["background"].color = color # remove this part to remove automatic bg colouring
    @sprites["background"].visible = DS_STYLE
    
    @sprites["background2"] = Sprite.new(@viewport2)
    @sprites["background2"].bitmap = pbBitmap("Graphics/Titles/gen_5_bg")
    @sprites["background2"].color = color # remove this part to remove automatic bg colouring
    
    @sprites["effect"] = AnimatedPlane.new(@viewport)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen_5_eff_ds") if DS_STYLE
    @sprites["effect"].visible = DS_STYLE
    @sprites["effect2"] = AnimatedPlane.new(@viewport2)
    @sprites["effect2"].bitmap = pbBitmap("Graphics/Titles/gen_5_eff")
    
    @sprites["shine"] = Sprite.new(@viewport2)
    @sprites["shine"].bitmap = pbBitmap("Graphics/Titles/gen_5_shine")
    @sprites["shine"].ox = @sprites["shine"].bitmap.width/2
    @sprites["shine"].oy = @sprites["shine"].bitmap.height/2
        
    @sprites["reflection"] = AnimatedPokemonSprite.new(@viewport2)
    @sprites["reflection"].setBitmap(pokemon)
    @sprites["reflection"].y = @viewport.rect.height - 32
    @sprites["reflection"].angle = 180
    @sprites["reflection"].mirror = true
    @sprites["reflection"].z = 5
    @sprites["reflection"].zoom_x = ($ResizeFactor==0.5) ? 2.0 : 1.5
    @sprites["reflection"].zoom_y = ($ResizeFactor==0.5) ? 2.0 : 1.5
    @sprites["reflection"].opacity = 255*0.2
    
    @sprites["sprite"] = AnimatedPokemonSprite.new(@viewport2)
    @sprites["sprite"].setBitmap(pokemon)
    @sprites["sprite"].x = @viewport.rect.width
    @sprites["sprite"].y = @viewport.rect.height - 64
    @sprites["sprite"].z = 10
    @sprites["sprite"].zoom_x = ($ResizeFactor==0.5) ? 2.0 : 1.5
    @sprites["sprite"].zoom_y = ($ResizeFactor==0.5) ? 2.0 : 1.5
    
    @sprites["shine"].x = @viewport.rect.width/2
    @sprites["shine"].y = @sprites["sprite"].y-@sprites["sprite"].height/2
    
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x = (@viewport.rect.width-@sprites["start"].bitmap.width)/2
    @sprites["start"].y = @viewport.rect.height - 24
    @sprites["start"].opacity = 0
    @sprites["start"].z = 45
    
    @sprites["logo"] = Sprite.new(@viewport)
    @bitmap1=pbBitmap(safe?("Graphics/Titles/pokelogo"))
    @bitmap2=pbBitmap(safe?("Graphics/Titles/pokelogo2"))
    @sprites["logo"].bitmap = Bitmap.new(@bitmap1.width,@bitmap1.height)
    @sprites["logo"].bitmap.blt(0,0,@bitmap2,Rect.new(0,0,@bitmap2.width,@bitmap2.height))
    @sprites["logo"].bitmap.blt(0,0,@bitmap1,Rect.new(0,0,@bitmap1.width,@bitmap1.height))
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/2
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = @viewport.rect.width/2 - 4
    @sprites["logo"].y = 24+64+99
    @sprites["logo"].y = @viewport.rect.height/2 if DS_STYLE
    @sprites["logo"].z = 5
    
    @logy = 2
    @logo = -17
  end
  
  def intro
    @viewport.tone = Tone.new(255,255,255)
    @viewport2.tone = Tone.new(255,255,255)
    @skip = false
  end
  
  def update
    @currentFrame+=1 if !@skip
    @sframe+=1
    @lframe+=1
    @sprites["reflection"].update
    @sprites["sprite"].update
    @sprites["shine"].angle+=1
    @sprites["logo"].y-=@logy
    y = DS_STYLE ? @viewport.rect.height/2 : 123
    @sprites["logo"].y = y if @sprites["logo"].y < y && @sframe < Graphics.frame_rate*10
    if @sprites["logo"].y == y-8
      @logy = -2
    elsif @sprites["logo"].y > y && @sprites["logo"].y <= y+2
      @logy = +2
      @sframe = 0
    end
    
    @sprites["start"].opacity+=@opacity
    @opacity=-17 if @sprites["start"].opacity>=255
    @opacity=+17 if @sprites["start"].opacity<=0
    @sprites["effect"].ox+=1
    @sprites["effect2"].ox+=1
    @sprites["sprite"].x+=(@viewport.rect.width/2 - @sprites["sprite"].x)*0.1
    @sprites["reflection"].x = @sprites["sprite"].x
    
    @viewport.tone.red-=17 if @viewport.tone.red > 0
    @viewport.tone.green-=17 if @viewport.tone.green > 0
    @viewport.tone.blue-=17 if @viewport.tone.blue > 0
    @viewport2.tone.red-=17 if @viewport2.tone.red > 0
    @viewport2.tone.green-=17 if @viewport2.tone.green > 0
    @viewport2.tone.blue-=17 if @viewport2.tone.blue > 0
    
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
  end
  
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      @viewport2.tone.red-=5
      @viewport2.tone.green-=5
      @viewport2.tone.blue-=5
      self.update
      wait(1)
    end
    raise Reset.new
  end
  
  
  def dispose
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewport2.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
# Styled to look like the XY games
#===============================================================================
class GenSixStyle
  
  def safe?(path)
    ext = getTSExtension
    if FileTest.exist?(path+ext+".png")
      return path+ext
    else
      return path
    end
  end
  
  def initialize
    # decides whether or not to show another layer of the title screen
    @showPoke = true
    # sound file for playing the title screen BGM
    bgm = GEN_SIX_BGM
    str = "Audio/BGM/"+pbResolveAudioFile(bgm).name
    @mp3 = (File.extname(str)==".ogg") ? true : false
    @skip = false
    @disposed = false
    @swapped = false
    @particles = 32
    @opacity = 5
    @pframe = [0,0,0,0,0]
    @speed = 3
    
    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames=getPlayTime(str).to_i*Graphics.frame_rate
    
    pbBGMPlay(bgm)
    pbWait(30) if @mp3
    @totalFrames-=100 if @mp3
    
    # creates all the necessary graphics
    h = @showPoke ? 2 : 1
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT*h)
    @viewport.z = 99999
    if @showPoke
      @viewport2 = Viewport.new(0,VIEWPORT_HEIGHT+VIEWPORT_OFFSET,Graphics.width,VIEWPORT_HEIGHT)
      @viewport2.z = 99990
      @viewport2.tone = Tone.new(-255,-255,-255)
    end
    @viewport2b = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport2b.z = 99999
    @sprites = {}
    
    self.drawPanorama if @showPoke
    
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = pbBitmap("Graphics/Titles/gen_6_bg")
    @sprites["effect"] = Sprite.new(@viewport)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen_6_effect")
    @sprites["effect"].ox = @sprites["effect"].bitmap.width/2
    @sprites["effect"].oy = @sprites["effect"].bitmap.height/2
    @sprites["effect"].x = @viewport.rect.width/2
    @sprites["effect"].y = @viewport.rect.height/(2*h)
    @sprites["effect2"] = Sprite.new(@viewport)
    @sprites["effect2"].bitmap = pbBitmap("Graphics/Titles/gen_6_effect2")
    @sprites["effect2"].ox = @sprites["effect2"].bitmap.width/2
    @sprites["effect2"].oy = @sprites["effect2"].bitmap.height/2
    @sprites["effect2"].x = @viewport.rect.width/2
    @sprites["effect2"].y = @viewport.rect.height/(2*h)
    @sprites["effect2"].opacity = 0
    @sprites["effect2"].z = 21
    @sprites["effect2"].angle = 20
    @effo = 1
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/Titles/gen_6_shine")
    @sprites["shine"].ox = @sprites["shine"].bitmap.width/2
    @sprites["shine"].oy = @sprites["shine"].bitmap.height/2
    @sprites["shine"].x = @viewport.rect.width/2 + 1
    @sprites["shine"].y = @viewport.rect.height/(2*h) - 2
    @sprites["shine"].zoom_x = 0
    @sprites["shine"].zoom_y = 0
    @sprites["shine"].opacity = 0
    
    for i in 0...@particles
      @sprites["p#{i}"] = AnimatedSpriteParticle.new(@viewport,rand(32))
      @sprites["p#{i}"].dy = @viewport.rect.height/(2*h)
      @sprites["p#{i}"].z = 21
      @sprites["p#{i}"].inverted = true
      @sprites["p#{i}"].refresh
    end
    
    @sprites["glow"] = Sprite.new(@viewport)
    @sprites["glow"].bitmap = pbBitmap("Graphics/Titles/gen_6_glow")
    @sprites["glow"].opacity = 0
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].bitmap = pbBitmap("Graphics/Titles/gen_6_overlay")
    @sprites["overlay"].z = 4
    
    @sprites["startrect"] = Sprite.new(@viewport2b)
    @sprites["startrect"].bitmap = Bitmap.new(@viewport2b.rect.width,@viewport2b.rect.height)
    @sprites["startrect"].bitmap.fill_rect(0,@sprites["startrect"].bitmap.height-38,@sprites["startrect"].bitmap.width,28,Color.new(0,0,0,92))
    @sprites["startrect"].visible = false
    
    @sprites["logo"] = Sprite.new(@viewport2b)
    @bitmap1=pbBitmap(safe?("Graphics/Titles/pokelogo"))
    @bitmap2=pbBitmap(safe?("Graphics/Titles/pokelogo2"))
    @sprites["logo"].bitmap = Bitmap.new(@bitmap1.width,@bitmap1.height)
    @sprites["logo"].bitmap.blt(0,0,@bitmap2,Rect.new(0,0,@bitmap2.width,@bitmap2.height))
    @sprites["logo"].bitmap.blt(0,0,@bitmap1,Rect.new(0,0,@bitmap1.width,@bitmap1.height))
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/2
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = @viewport2b.rect.width/2 - 4
    @sprites["logo"].y = @viewport2b.rect.height/2
    @sprites["logo"].zoom_x = 1.2
    @sprites["logo"].zoom_y = 1.2
    @sprites["logo"].opacity = 0
    @sprites["logo"].z = 5
    
    @sprites["start"] = Sprite.new(@viewport2b)
    @sprites["start"].bitmap = pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x = (@viewport2b.rect.width-@sprites["start"].bitmap.width)/2
    @sprites["start"].y = @viewport2b.rect.height - 32
    @sprites["start"].visible = false
    @sprites["start"].z = 5
    
    @glow = 1
  end
  
  def intro
    h = @showPoke ? 2 : 1
    @viewport.rect.height/=h
    @black1 = Sprite.new(@viewport)
    @black1.bitmap = Bitmap.new(@viewport.rect.width,2)
    @black1.bitmap.fill_rect(0,0,@black1.bitmap.width,2,Color.new(0,0,0))
    @black1.zoom_y = @viewport.rect.height/4
    @black1.z = 20
    @black2 = Sprite.new(@viewport)
    @black2.bitmap = @black1.bitmap.clone
    @black2.oy = 2
    @black2.zoom_y = @black1.zoom_y
    @black2.y = @viewport.rect.height
    @black2.z = 20
    @sprites["shine"].z = 22
    @box = Sprite.new(@viewport)
    @box.z = 10
    @box.bitmap = pbBitmap(safe?("Graphics/Titles/gen_6_letter2"))
    @box.ox = @box.bitmap.width/2
    @box.oy = @box.bitmap.height/2
    @box.x = @viewport.rect.width/2
    @box.y = @viewport.rect.height/2
    @box.zoom_x = 0
    @box.zoom_y = 0
    @box.angle = -12
    @letter = Sprite.new(@viewport)
    @letter.bitmap = pbBitmap(safe?("Graphics/Titles/gen_6_letter"))
    @letter.ox = @letter.bitmap.width/2
    @letter.oy = @letter.bitmap.height/2
    @letter.x = @box.x
    @letter.y = @box.y
    @letter.z = 25
    @letter.zoom_x = 0
    @letter.zoom_y = 0
    @letter.angle = -8
    f = @mp3 ? 100 : 120
    f.times do
      next if !wait(1,false)
      @sprites["shine"].opacity+=5
      @sprites["shine"].zoom_x+=0.0025
      @sprites["shine"].zoom_y+=0.0025
      self.update
    end
    @viewport.tone = Tone.new(200,200,200)
    @sprites["effect2"].z = 1
    for i in 0...@particles
      @sprites["p#{i}"].inverted = false
      @sprites["p#{i}"].refresh
    end    
    for i in 0...10
      next if !wait(1,false)
      @black1.zoom_y-=27 if i>6
      @black2.zoom_y-=27 if i>6
      @box.zoom_x+=0.11
      @box.zoom_y+=0.11
      self.update
    end
    5.times do
      next if !wait(1,false)
      @letter.zoom_x+=0.2
      @letter.zoom_y+=0.2
      self.update
    end
    @sprites["shine"].z = 1
    @sprites["shine"].zoom_x = 1
    @sprites["shine"].zoom_y = 1
    160.times do
      next if !wait(1,false)
      @box.angle+=0.1
      @box.zoom_x-=0.0015
      @box.zoom_y-=0.0015
      @letter.zoom_x+=0.0015
      @letter.zoom_y+=0.0015
      @letter.angle+=0.08
      self.update
    end
    for i in 0...@particles
      @sprites["p#{i}"].z = 1
    end
    f = @mp3 ? 38 : 48
    f.times do
      next if !wait(1,false)
      @black1.zoom_y-=1
      @black2.zoom_y-=1
      @box.zoom_x+=0.5
      @box.zoom_y+=0.5
      @letter.zoom_x+=0.001
      @letter.zoom_y+=0.001
      @letter.x+=@viewport.rect.width/16
      self.update
    end
    @black1.dispose
    @black2.dispose
    @box.dispose
    @letter.dispose
    50.times do
      @sprites["logo"].zoom_x-=0.004
      @sprites["logo"].zoom_y-=0.004
      @sprites["logo"].opacity+=5
      self.update
      wait(1,false)
    end
    @sprites["logo"].opacity+=5
    @viewport.tone = Tone.new(200,200,200)
    @sprites["logo"].tone = Tone.new(255,255,255)
    f = 160-36
    f-= 60 if @mp3
    f.times do
      self.update
      wait(1,false)
    end
    @sprites["start"].visible = true
    @sprites["start"].opacity = 255
    @opacity = -5
    @sprites["startrect"].visible = true
    #@viewport.rect.height*=h
    @viewport2.tone = Tone.new(0,0,0) if @showPoke
    @viewport2.rect.height = 0 if @showPoke && !DS_STYLE
    @skip = false
  end
  
  def update
    @currentFrame+=1 if !@skip
    @sprites["start"].opacity+=@opacity
    @opacity=-5 if @sprites["start"].opacity>=255
    @opacity=+5 if @sprites["start"].opacity<=0
    self.swapViewports if @showPoke && (@currentFrame==1060 || @currentFrame==1800)
    self.update1
    self.update2 if @showPoke
    if @currentFrame==@totalFrames
      self.restart if RESTART_TITLE
    end
  end
  
  def update1
    @sprites["effect"].angle+=1 if $ResizeFactor <= 1
    @sprites["effect2"].angle+=0.2 if $ResizeFactor <= 1
    @sprites["effect2"].opacity-=@effo
    if @sprites["effect2"].opacity < 32
      @effo = -1
    elsif @sprites["effect2"].opacity >= 255
      @effo = 1
    end
    @sprites["shine"].angle-=1 if $ResizeFactor <= 1
    @sprites["glow"].opacity-=@glow
    @sprites["logo"].tone.red-=2 if @sprites["logo"].tone.red > 0
    @sprites["logo"].tone.green-=2 if @sprites["logo"].tone.green > 0
    @sprites["logo"].tone.blue-=2 if @sprites["logo"].tone.blue > 0
    @viewport.tone.red-=5 if @viewport.tone.red > 0
    @viewport.tone.green-=5 if @viewport.tone.green > 0
    @viewport.tone.blue-=5 if @viewport.tone.blue > 0
    if @sprites["glow"].opacity <= 0
      @glow = -1
    elsif @sprites["glow"].opacity >= 255
      @glow = 1
    end
    for i in 0...@particles
      @sprites["p#{i}"].update
    end
  end
  
  def update2
    for i in 0...@pframe.length
      @pframe[i]+=1
    end
    @sprites["grass"].ox-=4
    @sprites["trees1"].ox-=1
    @sprites["trees2"].ox-=1 if @pframe[0]>1
    @sprites["trees3"].ox-=1 if @pframe[1]>2
    @sprites["clouds"].ox+=1 if @pframe[3]>1
    @sprites["pokemon"].src_rect.x+=@sprites["pokemon"].src_rect.width if @pframe[4]>@speed
    @sprites["pokemon"].src_rect.x=0 if @sprites["pokemon"].src_rect.x>=@sprites["pokemon"].bitmap.width
      
    @pframe[0]=0 if @pframe[0]>1
    @pframe[1]=0 if @pframe[1]>2
    @pframe[2]=0 if @pframe[2]>1
    @pframe[3]=0 if @pframe[3]>3
    @pframe[4]=0 if @pframe[4]>@speed
  end
        
  def swapViewports
    return if DS_STYLE
    view1 = @swapped ? @viewport2 : @viewport
    view2 = @swapped ? @viewport : @viewport2
    y = @swapped ? -6*4 : 6
    o = @swapped ? -4*4 : 6
    @viewport2b.tone = Tone.new(200,200,200) if !@swapped
    f = @swapped ? 32/2 : 64
    f.times do
      @viewport2b.tone.red-=5 if @viewport2b.tone.red > 0
      @viewport2b.tone.green-=5 if @viewport2b.tone.green > 0
      @viewport2b.tone.blue-=5 if @viewport2b.tone.blue > 0
      @viewport2.rect.height+=y
      @viewport.rect.height+=y
      @sprites["overlay"].opacity-=o
      view1.rect.y-=y
      view2.rect.y-=y
      @sprites["logo"].y-=y/6
      self.update
      wait(1,false)
    end
    @swapped = !@swapped
  end
  
  def drawPanorama
    viewport = @viewport2
    @sprites["background2"] = Sprite.new(viewport)
    @sprites["background2"].bitmap = pbBitmap("Graphics/Titles/Panorama/background")
    @sprites["clouds"] = AnimatedPlane.new(viewport)
    @sprites["clouds"].bitmap = pbBitmap("Graphics/Titles/Panorama/clouds")
    @sprites["mountains"] = Sprite.new(viewport)
    @sprites["mountains"].bitmap = pbBitmap("Graphics/Titles/Panorama/mountains")
    @sprites["trees3"] = AnimatedPlane.new(viewport)
    @sprites["trees3"].bitmap = pbBitmap("Graphics/Titles/Panorama/trees_3")
    @sprites["trees2"] = AnimatedPlane.new(viewport)
    @sprites["trees2"].bitmap = pbBitmap("Graphics/Titles/Panorama/trees_2")
    @sprites["trees1"] = AnimatedPlane.new(viewport)
    @sprites["trees1"].bitmap = pbBitmap("Graphics/Titles/Panorama/trees_1")    
    @sprites["grass"] = AnimatedPlane.new(viewport)
    @sprites["grass"].bitmap = pbBitmap("Graphics/Titles/Panorama/grass")
    @sprites["pokemon"] = Sprite.new(viewport)
    @sprites["pokemon"].bitmap = pbBitmap("Graphics/Titles/Panorama/pokemon")
    @sprites["pokemon"].src_rect.set(0,0,@sprites["pokemon"].bitmap.height,@sprites["pokemon"].bitmap.height)
    @sprites["pokemon"].x = viewport.rect.width - @sprites["pokemon"].src_rect.width - 32
    @sprites["pokemon"].y = viewport.rect.height - @sprites["pokemon"].src_rect.height
  
    @sprites["overlay2"] = Sprite.new(viewport)
    @sprites["overlay2"].bitmap = Bitmap.new(viewport.rect.width,viewport.rect.height)
    @sprites["overlay2"].z = 4
    @sprites["overlay2"].bitmap.fill_rect(0,@sprites["overlay2"].bitmap.height-38,@sprites["overlay2"].bitmap.width,28,Color.new(0,0,0,92)) if !DS_STYLE
  end
    
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      @viewport2.tone.red-=5
      @viewport2.tone.green-=5
      @viewport2.tone.blue-=5
      @viewport2b.tone.red-=5
      @viewport2b.tone.green-=5
      @viewport2b.tone.blue-=5
      self.update
      wait(1)
    end
    self.dispose(false)
    PlayEBDemo.new if defined?(DynamicPokemonSprite)
    raise Reset.new
  end
  
  def dispose(fade=true)
    pbFadeOutAndHide(@sprites) if fade
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewport2.dispose
    @viewport2b.dispose
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames,advance=true)
    return false if @skip
    frames.times do
      @currentFrame+=1 if advance
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
#  Default Essentials one
#===============================================================================
class EssentialsTitleScreen
  def initialize
    @skip = false
    @currentFrame = 0
    # calculates after how many frames the game will reset
    #@totalFrames=getPlayTime("Audio/BGM/#{bgm}")*Graphics.frame_rate
    @totalFrames = 90*Graphics.frame_rate
    @timer = 0
    
    @sprites = {}
    @sprites["pic"] = Sprite.new
    @sprites["pic"].bitmap = pbBitmap("Graphics/Titles/splash.png")
    
    @sprites["pic2"] = Sprite.new
    @sprites["pic2"].bitmap = pbBitmap("Graphics/Titles/start")
    @sprites["pic2"].y = 322
    
    data_system = pbLoadRxData("Data/System")
    pbBGMPlay(data_system.title_bgm)
  end

  def intro
    pbFadeInAndShow(@sprites)
  end

  def update
    @timer+=1
    @timer=0 if @timer>=80
    if @timer>=32
      @sprites["pic2"].opacity = 8*(@timer-32)
    else
      @sprites["pic2"].opacity = 255-(8*@timer)
    end
    if @currentFrame>=@totalFrames
      raise Reset.new if RESTART_TITLE
    end
  end
  
  def dispose(fade=true)
    pbFadeOutAndHide(@sprites) if fade
    pbDisposeSpriteHash(@sprites)
    @disposed=true
  end
  
  def disposed?
    return @disposed
  end
  
  def wait(frames)
    return if @skip
    frames.times do
      @currentFrame+=1
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
  end

end
#-------------------------------------------------------------------------------
#  Gen 5 Title Screen Pokemon sprite
#-------------------------------------------------------------------------------
class AnimatedPokemonSprite < Sprite
  def setBitmap(pokemon,back=false)                                          
    @bitmap = pbLoadPokemonBitmap(pokemon,back)                              
    self.bitmap = @bitmap.bitmap.clone
    self.ox = self.bitmap.width/2
    self.oy = self.bitmap.height
    metrics=load_data("Data/metrics.dat")
    self.oy+=metrics[2][pokemon.species]
    self.oy-=metrics[1][pokemon.species]
  end
  
  def animatedBitmap; return @bitmap; end
  def width; return @bitmap.width; end
  def height; return @bitmap.height; end
  
  def update
    @bitmap.update
    self.bitmap = @bitmap.bitmap.clone
  end
end
#-------------------------------------------------------------------------------
#  Gen 6 Title Screen particles
#-------------------------------------------------------------------------------
class AnimatedSpriteParticle < Sprite
  attr_accessor :inverted
  attr_accessor :repeat
  attr_accessor :count
  attr_accessor :dy
  attr_accessor :dx
  def initialize(viewport,delay=0)
    @dx = viewport.rect.width/2
    @dy = viewport.rect.height/4
    @repeat = -1
    @count = 0
    super(viewport)
    @inverted = true
    self.refresh
    @delay = delay
    @frame = 0
    self.visible = false
  end
  
  def update
    return if @repeat > 0 && @count > @repeat
    @frame+=1
    return if @frame < @delay
    self.visible = true
    @px-= @inverted ? (@px-@pos[0])*(0.002*@speed) : (@pos[0]-@px)*(0.002*@speed)
    @py-= @inverted ? (@py-@pos[1])*(0.002*@speed) : (@pos[1]-@py)*(0.002*@speed)
    self.x = @px
    self.y = @py
    s = @inverted ? 0.5 : 1
    self.opacity-=0.5*@speed*s
    self.refresh if self.opacity <= 0
  end
  
  def refresh
    self.opacity = 255
    self.x = @dx
    self.y = @dy
    x = rand(@dx*2 + 32*4)-32*2
    y = rand(@dy*2 + 32*4)-32*2
    x1 = rand(2)<1 ? -rand(32) : @dx*2+rand(32)
    y1 = @dy-46+rand(92)
    @pos = [
      @inverted ? @dx : x,
      @inverted ? @dy : y
    ]
    @px = @inverted ? x1 : @dx
    @py = @inverted ? y1 : @dy
    @speed = (rand(16)+1)*0.5
    @speed*=4 if @inverted
    if rand(2) < 1
      self.bitmap = pbBitmap("Graphics/Titles/gen_6_particle2")
    else
      self.bitmap = pbBitmap("Graphics/Titles/gen_6_particle")
    end
    self.ox = self.bitmap.width/2
    self.oy = self.bitmap.height/2
    @count+=1 if @repeat > 0
  end
end
#-------------------------------------------------------------------------------
#  Gen 6 EB demo
#-------------------------------------------------------------------------------
# If the Elite Battle system is detected, the game will play a little demo of it
# after the title screen finishes playing.
class PlayEBDemo
  
  def initialize
    @viewport = {}
    $Trainer = PokeBattle_Trainer.new("",0)
    
    @skip = false
    @files = readDirectoryFiles("Graphics/Titles/Extra/",["*.png"]).sort_by { |x| x[/\d+/].to_i }
    return if @files.length<7
    pbBGMPlay("global_opening.ogg")
    
    @sprites = {}
    @viewport["2"] = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    @viewport["2"].tone = Tone.new(-255,-255,-255)
    @ballframe = 0
    @sprites["pokeball"]=Sprite.new(@viewport["2"])
    @sprites["pokeball"].bitmap=BitmapCache.load_bitmap("Graphics/Pictures/pokeballs")
    @sprites["pokeball"].src_rect.set(0,@ballframe*40,41,40)
    @sprites["pokeball"].ox=20
    @sprites["pokeball"].oy=20
    @sprites["pokeball"].zoom_x = 1.5
    @sprites["pokeball"].zoom_y = 1.5
    @sprites["pokeball"].z = 20
    @sprites["pokeball"].x = @viewport["2"].rect.width/2
    @sprites["pokeball"].y = @viewport["2"].rect.height*0.6-128
    for i in 1..3
      y = [-VIEWPORT_HEIGHT,0,VIEWPORT_HEIGHT]
      @viewport["#{i}"] = Viewport.new((Graphics.width/3+5)*(i-1),y[i-1],Graphics.width/3-8,VIEWPORT_HEIGHT) if i!=2
      @viewport["#{i}"].z = 1 if i!=2
      pkmn = PokeBattle_Pokemon.new(EB_SPECIES[i-1],5)
      
      @sprites["bg#{i}"] = Sprite.new(@viewport["#{i}"])
      @sprites["bg#{i}"].bitmap = Bitmap.new(@viewport["#{i}"].rect.width,@viewport["#{i}"].rect.height-24)
      bmp = pbBitmap("Graphics/Battlebacks/battlebg#{EB_BG[i-1]}")
      @sprites["bg#{i}"].bitmap.stretch_blt(Rect.new(0,0,@viewport["#{i}"].rect.width,@viewport["#{i}"].rect.height),bmp,Rect.new(bmp.width/4,bmp.height/4,bmp.width/2,bmp.height/2))
      @sprites["bg#{i}"].ox = @sprites["bg#{i}"].bitmap.width/2
      @sprites["bg#{i}"].oy = @sprites["bg#{i}"].bitmap.height/2
      @sprites["bg#{i}"].x = @viewport["#{i}"].rect.width/2
      @sprites["bg#{i}"].y = @viewport["#{i}"].rect.height/2
      
      @sprites["base#{i}"] = Sprite.new(@viewport["#{i}"])
      @sprites["base#{i}"].bitmap = pbBitmap("Graphics/Battlebacks/enemybase#{EB_BASE[i-1]}")
      @sprites["base#{i}"].ox = @sprites["base#{i}"].bitmap.width/2
      @sprites["base#{i}"].oy = @sprites["base#{i}"].bitmap.height/2
      @sprites["base#{i}"].x = @viewport["#{i}"].rect.width/2
      @sprites["base#{i}"].y = @viewport["#{i}"].rect.height*0.6
      @sprites["base#{i}"].zoom_x = 1.5
      @sprites["base#{i}"].zoom_y = 1.5
      
      @sprites["pokemon#{i}"]=DynamicPokemonSprite.new(false,0,@viewport["#{i}"])
      @sprites["pokemon#{i}"].setPokemonBitmap(pkmn,false)
      @sprites["pokemon#{i}"].mirror = true
      @sprites["pokemon#{i}"].x = @sprites["base#{i}"].x
      @sprites["pokemon#{i}"].y = @sprites["base#{i}"].y
      @sprites["pokemon#{i}"].zoom_x = 1.5
      @sprites["pokemon#{i}"].zoom_y = 1.5
    end
    @viewport["3"].rect.height = 0
    @oy = @sprites["pokemon2"].oy
    @sprites["pokemon2"].oy = @sprites["pokemon2"].bitmap.width/2
    @sprites["pokemon2"].y-=128+@sprites["pokemon2"].oy/2
    @sprites["pokemon2"].zoom_x = 0
    @sprites["pokemon2"].zoom_y = 0
    @sprites["pokemon2"].tone = Tone.new(255,255,255)
    @sprites["pokemon2"].showshadow = false
    
    self.play
    @viewport.dispose
    self.dispose
  end
  
  def play
    15.times do
      @viewport["2"].tone.red+=17
      @viewport["2"].tone.green+=17
      @viewport["2"].tone.blue+=17
      @sprites["pokeball"].src_rect.set(0,@ballframe*40,41,40)
      wait(1)
    end
    wait(1)
    8.times do
      @sprites["pokeball"].src_rect.set(0,@ballframe*40,41,40)
      wait(1)
    end
    @sprites["pokeball"].visible=false
    8.times do
      @sprites["pokemon2"].zoom_x+=0.125*1.5
      @sprites["pokemon2"].zoom_y+=0.125*1.5
      wait(1)
    end
    8.times do
      @sprites["pokemon2"].tone.red-=32
      @sprites["pokemon2"].tone.green-=32
      @sprites["pokemon2"].tone.blue-=32
      wait(1)
    end
    @sprites["pokemon2"].y+=@sprites["pokemon2"].oy/2
    @sprites["pokemon2"].oy = @oy
    8.times do
      @sprites["pokemon2"].y+=16
      wait(1)
    end
    @sprites["pokemon2"].showshadow = true
    4.times do
      @viewport["2"].rect.y+=2
      wait(1)
    end
    4.times do
      @viewport["2"].rect.y-=2
      wait(1)
    end
    wait(8)
    8.times do
      @viewport["2"].rect.x+=22
      @viewport["2"].rect.width-=44
      @sprites["bg2"].x = @viewport["2"].rect.width/2
      @sprites["base2"].x = @viewport["2"].rect.width/2
      @sprites["pokemon2"].x = @sprites["base2"].x
      wait(1)
    end
    wait(16)
    8.times do
      @viewport["1"].rect.y+=48
      wait(1)
    end
    wait(16)
    8.times do
      @viewport["3"].rect.y-=48
      @viewport["3"].rect.height+=48
      wait(1)
    end
    wait(24)
    16.times do
      @viewport["1"].rect.y-=24
      @viewport["2"].rect.y+=24
      @viewport["2"].rect.height-=24
      @viewport["3"].rect.y-=24
      wait(1)
    end
    self.dispose
    wait(8)
    @viewport = Viewport.new(0,0,Graphics.width,VIEWPORT_HEIGHT)
    for i in 0..1
      pbDisposeSpriteHash(@sprites)
      f = [1,-1][i]
      @viewport.tone = Tone.new(255,255,255)
      @sprites["#{i}"] = Sprite.new(@viewport)
      @sprites["#{i}"].bitmap = pbBitmap("Graphics/Titles/Extra/#{@files[i]}")
      @sprites["#{i}"].ox = @sprites["#{i}"].bitmap.width/2
      @sprites["#{i}"].oy = @sprites["#{i}"].bitmap.height/2
      @sprites["#{i}"].x = @viewport.rect.width/2
      @sprites["#{i}"].y = @viewport.rect.height/2
      @sprites["#{i}"].angle=-4*f
      51.times do
        @viewport.tone.red-=10 if @viewport.tone.red>0
        @viewport.tone.green-=10 if @viewport.tone.green>0
        @viewport.tone.blue-=10 if @viewport.tone.blue>0
        @sprites["#{i}"].angle+=0.1*f
        
        wait(1)
      end
    end
    pbDisposeSpriteHash(@sprites)
    for i in 2..5
      @sprites["#{i}"] = Sprite.new(@viewport)
      @sprites["#{i}"].bitmap = pbBitmap("Graphics/Titles/Extra/#{@files[i]}")
      @sprites["#{i}"].ox = @sprites["#{i}"].bitmap.width/2
      @sprites["#{i}"].oy = @sprites["#{i}"].bitmap.height/2
      @sprites["#{i}"].x = -@viewport.rect.width/2
      @sprites["#{i}"].y = @viewport.rect.height/2
      16.times do
        @sprites["#{i}"].x+=32
        if i>2
          @sprites["#{i-1}"].opacity-=16
        end
        wait(1)
      end
      wait(8)
    end
    wait(8)
    pbDisposeSpriteHash(@sprites)
    for i in 6..6
      @viewport.tone = Tone.new(255,255,255)
      @sprites["#{i}"] = Sprite.new(@viewport)
      @sprites["#{i}"].bitmap = pbBitmap("Graphics/Titles/Extra/#{@files[i]}")
      @sprites["#{i}"].ox = @sprites["#{i}"].bitmap.width/2
      @sprites["#{i}"].oy = @sprites["#{i}"].bitmap.height/2
      @sprites["#{i}"].x = @viewport.rect.width/2
      @sprites["#{i}"].y = @viewport.rect.height/2
      51.times do
        @viewport.tone.red-=5
        @viewport.tone.green-=5
        @viewport.tone.blue-=5
        wait(1)
      end
    end
    wait(12)
    pbDisposeSpriteHash(@sprites)
    wait(40)
    pbBGMStop(1.0)
    wait(20)
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@viewport) if @viewport.is_a?(Hash)
  end
  
  def wait(frames)
    return false if @skip
    frames.times do
      Graphics.update
      Input.update
      for i in 1..3
        @sprites["pokemon#{i}"].update if @sprites["pokemon#{i}"]
      end
      @ballframe+=1
      @ballframe=0 if @ballframe > 7
      @skip=true if Input.trigger?(Input::C)
    end
    return true
  end
  
end
#===============================================================================
#  Just a little utility I made to load up all the correct files from a directory
#===============================================================================
def readDirectoryFiles(directory,formats)
  files=[]
  Dir.chdir(directory){
    for i in 0...formats.length
      Dir.glob(formats[i]){|f| files.push(f) }
    end
  }
  return files
end
#===============================================================================
#  Misc. scripting tools
#===============================================================================
def pbBitmap(name)
  if !pbResolveBitmap(name).nil?
    bmp = BitmapCache.load_bitmap(name)
  else
    p "Image located at '#{name}' was not found!" if $DEBUG
    bmp = Bitmap.new(1,1)
  end
  return bmp
end
#===============================================================================
def getTSExtension
  ext = ""
  ext = " (gen 6 proj)" if PokeBattle_Scene.method_defined?(:pbDisplayEffect)
  ext = " (bw kit)" if defined?(SCREENDUALHEIGHT)
  ext = " (ds kit)" if defined?(SCREEN_HEIGHT)
  return ext
end
#===============================================================================
# Don't touch these
$memDebug = $DEBUG
$DEBUG = false if PLAY_ON_DEBUG
# Used to configure the system for potential DS styles
#-----------------------------------------------------
if VIEWPORT_OFFSET==0
  if defined?(SCREEN_HEIGHT) # PEDS v2 (Venom12)
    VIEWPORT_HEIGHT = SCREEN_HEIGHT
    VIEWPORT_OFFSET = DEFAULTSCREENHEIGHT - SCREEN_HEIGHT*2
  elsif defined?(SCREENDUALHEIGHT) # PEBW v3 (KleinStudio)
    VIEWPORT_HEIGHT = DEFAULTSCREENHEIGHT
    VIEWPORT_OFFSET = SCREENDUALHEIGHT - DEFAULTSCREENHEIGHT*2
  end
end
DS_STYLE = (VIEWPORT_OFFSET > 0)