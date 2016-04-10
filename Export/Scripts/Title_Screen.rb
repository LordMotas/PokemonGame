#===============================================================================
#  New animated Title Screens for Pokemon Essentials
#    by Luka S.J.
#
#  Adds new visual styles to the Pokemon Essentials title screen, and animates
#  depending on the style selected
#
#  Slightly modified for gen 6
#===============================================================================


class Scene_Intro
  
  alias main_old main
  def main
    Graphics.transition(0)
    # Loads up a species cry for the title screen
    species=PBSpecies::PIKACHU
    @cry=pbCryFile(species)
    # Cycles through the intro pictures
    @skip=false
    self.cyclePics(@pics)
    # Selects title screen style
    @screen=GenSixStyle.new
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
    pbSEPlay(@cry,100,100) if @cry
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
  
  def wait(frames)
    return if @skip
    frames.times do
      Graphics.update
      Input.update
      @skip=true if Input.trigger?(Input::C)
    end
  end
end

#===============================================================================
# Styled to look like the FRLG games
#===============================================================================
class GenSixStyle
  def initialize
    # sound file for playing the title screen BGM
    bgm="rse opening"
    @skip=false
    # speed of the effect movement
    @speed=1
    @opacity=2
    @frame=0
    @disposed=false
    
    @currentFrame=0
    # calculates after how many frames the game will reset
    #@totalFrames=getPlayTime("Audio/BGM/#{bgm}")*Graphics.frame_rate
    @totalFrames=100*Graphics.frame_rate
    pbBGMPlay(bgm)
    
    # creates all the necessary graphics
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    
    @sprites["bg"]=Sprite.new(@viewport)
    @sprites["bg"].bitmap=pbBitmap("Graphics/Titles/gen6_bg")
    @sprites["bg"].tone=Tone.new(255,255,255)
    @sprites["bg"].opacity=0
    #@sprites["poke1"]=Sprite.new(@viewport)
    #@sprites["poke1"].bitmap=pbBitmap("Graphics/Titles/gen6_poke1")
    #@sprites["poke1"].opacity=0
    #@sprites["poke2"]=Sprite.new(@viewport)
    #@sprites["poke2"].bitmap=pbBitmap("Graphics/Titles/gen3_poke2")
    #@sprites["poke2"].opacity=0
    @sprites["effect"]=AnimatedPlane.new(@viewport)
    @sprites["effect"].bitmap=pbBitmap("Graphics/Titles/gen6_effect")
    @sprites["effect"].visible=false
    @sprites["logo2"]=Sprite.new(@viewport)
    @sprites["logo2"].bitmap=pbBitmap("Graphics/Titles/pokelogo2")
    @sprites["logo2"].x=(Graphics.width-@sprites["logo2"].bitmap.width)/2
    @sprites["logo2"].y=24-32
    @sprites["logo2"].opacity=0
    @sprites["logo1"]=Sprite.new(@viewport)
    @sprites["logo1"].bitmap=pbBitmap("Graphics/Titles/pokelogo")
    @sprites["logo1"].x=(Graphics.width-@sprites["logo1"].bitmap.width)/2
    @sprites["logo1"].y=24+64
    @sprites["logo1"].opacity=0
    @sprites["logo3"]=Sprite.new(@viewport)
    @sprites["logo3"].bitmap=pbBitmap("Graphics/Titles/pokelogo")
    @sprites["logo3"].tone=Tone.new(255,255,255)
    @sprites["logo3"].x=(Graphics.width-@sprites["logo3"].bitmap.width)/2-32
    @sprites["logo3"].y=24+64
    @sprites["logo3"].src_rect.set(-34,0,34,230)
    @sprites["start"]=Sprite.new(@viewport)
    @sprites["start"].bitmap=pbBitmap("Graphics/Titles/pokestart")
    @sprites["start"].x=(Graphics.width-@sprites["start"].bitmap.width)/2
    @sprites["start"].y=312
    @sprites["start"].visible=false
  end
  def intro
    16.times do
      @sprites["logo1"].opacity+=16
      wait(1)
    end
    wait(16)
    12.times do
      @sprites["logo3"].x+=34
      @sprites["logo3"].src_rect.x+=34
      wait(1)
    end
    @sprites["logo3"].x=(Graphics.width-@sprites["logo3"].bitmap.width)/2-32
    @sprites["logo3"].src_rect.x=-34
    wait(32)
    2.times do
      12.times do
        @sprites["logo3"].x+=34
        @sprites["logo3"].src_rect.x+=34
        @sprites["bg"].opacity+=21.5
        wait(1)
      end
      @sprites["logo3"].x=(Graphics.width-@sprites["logo3"].bitmap.width)/2-32
      @sprites["logo3"].src_rect.x=-34
      wait(4)
      16.times do
        @sprites["bg"].opacity-=16
        wait(1)
      end
      wait(32)
    end
    @sprites["logo3"].visible=false
    16.times do
      @sprites["logo1"].y-=2
      wait(1)
    end
    16.times do
      @sprites["logo1"].y-=2
      @sprites["logo2"].y+=2
      @sprites["logo2"].opacity+=16
      wait(1)
    end
    wait(56)
    @sprites["bg"].tone=Tone.new(0,0,0)
    @sprites["bg"].opacity=255
    #@sprites["poke1"].opacity=255
    @sprites["effect"].visible=true
    
  end
  
  def update
    @currentFrame+=1
    @frame+=1
    @sprites["effect"].oy+=@speed
    #@sprites["poke2"].opacity+=@opacity
    #@opacity=-2 if @sprites["poke2"].opacity>=255
    #@opacity=+2 if @sprites["poke2"].opacity<=0
    if @frame==8
      @sprites["start"].visible=true
    elsif @frame==24
      @sprites["start"].visible=false
      @frame=0
    end
      
    if @currentFrame>=@totalFrames
      raise Reset.new
    end
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

#===============================================================================
#  Misc. scripting tools
#===============================================================================

def pbBitmap(name)
  return BitmapCache.load_bitmap(name)
end
     