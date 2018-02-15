#===============================================================================
# Pokémon icons
#===============================================================================
class PokemonBoxIcon < IconSprite
  def initialize(pokemon,viewport=nil)
    super(0,0,viewport)
    @pokemon = pokemon
    @release = Interpolator.new
    @startRelease = false
    self.setBitmap(pbPokemonIconFile(pokemon)) if pokemon
    self.src_rect = Rect.new(0,0,64,64)
  end

  def release
    self.ox = 32
    self.oy = 32
    self.x += 32
    self.y += 32
    @release.tween(self,[
       [Interpolator::ZOOM_X,0],
       [Interpolator::ZOOM_Y,0],
       [Interpolator::OPACITY,0]
    ],100)
    @startRelease = true
  end

  def releasing?
    return @release.tweening?
  end

  def update
    super
    @release.update
    self.color = Color.new(0,0,0,0)
    dispose if @startRelease && !releasing?
  end
end



#===============================================================================
# Pokémon sprite
#===============================================================================
class MosaicPokemonSprite < PokemonSprite
  attr_reader :mosaic

  def initialize(*args)
    super(*args)
    @mosaic = 0
    @inrefresh = false
    @mosaicbitmap = nil
    @mosaicbitmap2 = nil
    @oldbitmap = self.bitmap
  end

  def dispose
    super
    @mosaicbitmap.dispose if @mosaicbitmap
    @mosaicbitmap = nil
    @mosaicbitmap2.dispose if @mosaicbitmap2
    @mosaicbitmap2 = nil
  end

  def mosaic=(value)
    @mosaic = value
    @mosaic = 0 if @mosaic<0
    mosaicRefresh(@oldbitmap)
  end

  def bitmap=(value)
    super
    mosaicRefresh(value)
  end

  def mosaicRefresh(bitmap)
    return if @inrefresh
    @inrefresh = true
    @oldbitmap = bitmap
    if @mosaic<=0 || !@oldbitmap
      @mosaicbitmap.dispose if @mosaicbitmap
      @mosaicbitmap = nil
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap2 = nil
      self.bitmap = @oldbitmap
    else
      newWidth  = [(@oldbitmap.width/@mosaic),1].max
      newHeight = [(@oldbitmap.height/@mosaic),1].max
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap = pbDoEnsureBitmap(@mosaicbitmap,newWidth,newHeight)
      @mosaicbitmap.clear
      @mosaicbitmap2 = pbDoEnsureBitmap(@mosaicbitmap2,@oldbitmap.width,@oldbitmap.height)
      @mosaicbitmap2.clear
      @mosaicbitmap.stretch_blt(Rect.new(0,0,newWidth,newHeight),@oldbitmap,@oldbitmap.rect)
      @mosaicbitmap2.stretch_blt(
         Rect.new(-@mosaic/2+1,-@mosaic/2+1,
         @mosaicbitmap2.width,@mosaicbitmap2.height),
         @mosaicbitmap,Rect.new(0,0,newWidth,newHeight))
      self.bitmap = @mosaicbitmap2
    end
    @inrefresh = false
  end
end



class AutoMosaicPokemonSprite < MosaicPokemonSprite
  def update
    super
    self.mosaic -= 1
  end
end



#===============================================================================
# Cursor
#===============================================================================
class PokemonBoxArrow < SpriteWrapper
  attr_accessor :quickswap

  def initialize(viewport=nil)
    super(viewport)
    @frame = 0
    @holding = false
    @updating = false
    @quickswap = false
    @grabbingState = 0
    @placingState = 0
    @heldpkmn = nil
    @handsprite = ChangelingSprite.new(0,0,viewport)
    @handsprite.addBitmap("point1","Graphics/Pictures/Storage/cursor_point_1")
    @handsprite.addBitmap("point2","Graphics/Pictures/Storage/cursor_point_2")
    @handsprite.addBitmap("grab","Graphics/Pictures/Storage/cursor_grab")
    @handsprite.addBitmap("fist","Graphics/Pictures/Storage/cursor_fist")
    @handsprite.addBitmap("point1q","Graphics/Pictures/Storage/cursor_point_1_q")
    @handsprite.addBitmap("point2q","Graphics/Pictures/Storage/cursor_point_2_q")
    @handsprite.addBitmap("grabq","Graphics/Pictures/Storage/cursor_grab_q")
    @handsprite.addBitmap("fistq","Graphics/Pictures/Storage/cursor_fist_q")
    @handsprite.changeBitmap("fist")
    @spriteX = self.x
    @spriteY = self.y
  end

  def dispose
    @handsprite.dispose
    @heldpkmn.dispose if @heldpkmn
    super
  end

  def heldPokemon
    @heldpkmn = nil if @heldpkmn && @heldpkmn.disposed?
    @holding = false if !@heldpkmn
    return @heldpkmn
  end

  def visible=(value)
    super
    @handsprite.visible = value
    sprite = heldPokemon
    sprite.visible = value if sprite
  end

  def color=(value)
    super
    @handsprite.color = value
    sprite = heldPokemon
    sprite.color = value if sprite
  end

  def holding?
    return self.heldPokemon && @holding
  end

  def grabbing?
    return @grabbingState>0
  end

  def placing?
    return @placingState>0
  end

  def x=(value)
    super
    @handsprite.x = self.x
    @spriteX = x if !@updating
    heldPokemon.x = self.x if holding?
  end

  def y=(value)
    super
    @handsprite.y = self.y
    @spriteY = y if !@updating
    heldPokemon.y = self.y+16 if holding?
  end

  def z=(value)
    super
    @handsprite.z = value
  end

  def setSprite(sprite)
    if holding?
      @heldpkmn = sprite
      @heldpkmn.viewport = self.viewport if @heldpkmn
      @heldpkmn.z = 1 if @heldpkmn
      @holding = false if !@heldpkmn
      self.z = 2
    end
  end

  def deleteSprite
    @holding = false
    if @heldpkmn
      @heldpkmn.dispose
      @heldpkmn = nil
    end
  end

  def grab(sprite)
    @grabbingState = 1
    @heldpkmn = sprite
    @heldpkmn.viewport = self.viewport
    @heldpkmn.z = 1
    self.z = 2
  end

  def place
    @placingState = 1
  end

  def release
    @heldpkmn.release if @heldpkmn
  end

  def update
    @updating = true
    super
    heldpkmn = heldPokemon
    heldpkmn.update if heldpkmn
    @handsprite.update
    @holding = false if !heldpkmn
    if @grabbingState>0
      if @grabbingState<=8
        @handsprite.changeBitmap((@quickswap) ? "grabq" : "grab")
        self.y = @spriteY+(@grabbingState)*2
        @grabbingState += 1
      elsif @grabbingState<=16
        @holding = true
        @handsprite.changeBitmap((@quickswap) ? "fistq" : "fist")
        self.y = @spriteY+(16-@grabbingState)*2
        @grabbingState += 1
      else
        @grabbingState = 0
      end
    elsif @placingState>0
      if @placingState<=8
        @handsprite.changeBitmap((@quickswap) ? "fistq" : "fist")
        self.y = @spriteY+(@placingState)*2
        @placingState += 1
      elsif @placingState<=16
        @holding = false
        @heldpkmn = nil
        @handsprite.changeBitmap((@quickswap) ? "grabq" : "grab")
        self.y = @spriteY+(16-@placingState)*2
        @placingState += 1
      else
        @placingState = 0
      end
    elsif holding?
      @handsprite.changeBitmap((@quickswap) ? "fistq" : "fist")
    else
      self.x = @spriteX
      self.y = @spriteY
      if (@frame/20)==0
        @handsprite.changeBitmap((@quickswap) ? "point1q" : "point1")
      else
        @handsprite.changeBitmap((@quickswap) ? "point2q" : "point2")
      end
    end
    @frame += 1
    @frame = 0 if @frame==40
    @updating = false
  end
end



#===============================================================================
# Box
#===============================================================================
class PokemonBoxSprite < SpriteWrapper
  attr_accessor :refreshBox
  attr_accessor :refreshSprites
  def initialize(storage,boxnumber,viewport=nil)
    super(viewport)
    @storage = storage
    @boxnumber = boxnumber
    @refreshBox = true
    @refreshSprites = true
    @pokemonsprites = []
    for i in 0...30
      @pokemonsprites[i] = nil
      pokemon = @storage[boxnumber,i]
      @pokemonsprites[i] = PokemonBoxIcon.new(pokemon,viewport)
    end
    @contents = BitmapWrapper.new(324,296)
    self.bitmap = @contents
    self.x = 184
    self.y = 18
    refresh
  end

  def dispose
    if !disposed?
      for i in 0...30
        @pokemonsprites[i].dispose if @pokemonsprites[i]
        @pokemonsprites[i] = nil
      end
      @boxbitmap.dispose
      @contents.dispose
      super
    end
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    if @refreshSprites
      for i in 0...30
        if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
          @pokemonsprites[i].color = value
        end
      end
    end
    refresh
  end

  def visible=(value)
    super
    for i in 0...30
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
    refresh
  end

  def getBoxBitmap
    if !@bg || @bg!=@storage[@boxnumber].background
      curbg = @storage[@boxnumber].background
      if !curbg || (curbg.is_a?(String) && curbg.length==0)
        @bg = @boxnumber%PokemonStorage::BASICWALLPAPERQTY
      else
        if curbg.is_a?(String) && curbg[/^box(\d+)$/]
          curbg = $~[1].to_i
          @storage[@boxnumber].background = curbg
        end
        @bg = curbg
      end
      if !@storage.isAvailableWallpaper(@bg)
        @bg = @boxnumber%PokemonStorage::BASICWALLPAPERQTY
        @storage[@boxnumber].background = @bg
      end
      @boxbitmap.dispose if @boxbitmap
      @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/box_#{@bg}")
    end
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index,sprite)
    @pokemonsprites[index] = sprite
    refresh
  end

  def grabPokemon(index,arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      refresh
    end
  end

  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    refresh
  end

  def refresh
    if @refreshBox
      boxname = @storage[@boxnumber].name
      getBoxBitmap
      @contents.blt(0,0,@boxbitmap.bitmap,Rect.new(0,0,324,296))
      pbSetSystemFont(@contents)
      widthval = @contents.text_size(boxname).width
      xval = 162-(widthval/2)
      pbDrawShadowText(@contents,xval,8,widthval,32,boxname,Color.new(248,248,248),Color.new(40,48,48))
      @refreshBox = false
    end
    yval = self.y+30
    for j in 0...5
      xval = self.x+10
      for k in 0...6
        sprite = @pokemonsprites[j*6+k]
        if sprite && !sprite.disposed?
          sprite.viewport = self.viewport
          sprite.x = xval
          sprite.y = yval
          sprite.z = 0
        end
        xval += 48
      end
      yval += 48
    end
  end

  def update
    super
    for i in 0...30
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].update
      end
    end
  end
end



#===============================================================================
# Party pop-up panel
#===============================================================================
class PokemonBoxPartySprite < SpriteWrapper
  def initialize(party,viewport=nil)
    super(viewport)
    @party = party
    @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/overlay_party")
    @pokemonsprites = []
    for i in 0...6
      @pokemonsprites[i] = nil
      pokemon = @party[i]
      if pokemon
        @pokemonsprites[i] = PokemonBoxIcon.new(pokemon,viewport)
      end
    end
    @contents = BitmapWrapper.new(172,352)
    self.bitmap = @contents
    self.x = 182
    self.y = Graphics.height-352
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    for i in 0...6
      @pokemonsprites[i].dispose if @pokemonsprites[i]
    end
    @boxbitmap.dispose
    @contents.dispose
    super
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].color = pbSrcOver(@pokemonsprites[i].color,value)
      end
    end
  end

  def visible=(value)
    super
    for i in 0...6
      if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        @pokemonsprites[i].visible = value
      end
    end
  end

  def getPokemon(index)
    return @pokemonsprites[index]
  end

  def setPokemon(index,sprite)
    @pokemonsprites[index] = sprite
    @pokemonsprites.compact!
    refresh
  end

  def grabPokemon(index,arrow)
    sprite = @pokemonsprites[index]
    if sprite
      arrow.grab(sprite)
      @pokemonsprites[index] = nil
      @pokemonsprites.compact!
      refresh
    end
  end

  def deletePokemon(index)
    @pokemonsprites[index].dispose
    @pokemonsprites[index] = nil
    @pokemonsprites.compact!
    refresh
  end

  def refresh
    @contents.blt(0,0,@boxbitmap.bitmap,Rect.new(0,0,172,352))
    pbDrawTextPositions(self.bitmap,[
       [_INTL("Back"),86,242,2,Color.new(248,248,248),Color.new(80,80,80),1]
    ])
    
    xvalues = [18,90,18,90,18,90]
    yvalues = [2,18,66,82,130,146]
    for j in 0...6
      @pokemonsprites[j] = nil if @pokemonsprites[j] && @pokemonsprites[j].disposed?
    end
    @pokemonsprites.compact!
    for j in 0...6
      sprite = @pokemonsprites[j]
      if sprite && !sprite.disposed?
        sprite.viewport = self.viewport
        sprite.x = self.x+xvalues[j]
        sprite.y = self.y+yvalues[j]
        sprite.z = 0
      end
    end
  end

  def update
    super
    for i in 0...6
      @pokemonsprites[i].update if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
    end
  end
end



#===============================================================================
# Pokémon storage visuals
#===============================================================================
class PokemonStorageScene
  attr_reader :quickswap

  def initialize
    @command = 1
  end

  def pbStartBox(screen,command)
    @screen = screen
    @storage = screen.storage
    @bgviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @bgviewport.z = 99999
    @boxviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @boxviewport.z = 99999
    @boxsidesviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @boxsidesviewport.z = 99999
    @arrowviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @arrowviewport.z = 99999
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @selection = 0
    @quickswap = false
    @sprites = {}
    @choseFromParty = false
    @command = command
    addBackgroundPlane(@sprites,"background","Storage/bg",@bgviewport)
    @sprites["box"] = PokemonBoxSprite.new(@storage,@storage.currentBox,@boxviewport)
    @sprites["boxsides"] = IconSprite.new(0,0,@boxsidesviewport)
    @sprites["boxsides"].setBitmap("Graphics/Pictures/Storage/overlay_main")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@boxsidesviewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["pokemon"] = AutoMosaicPokemonSprite.new(@boxsidesviewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Center)
    @sprites["pokemon"].x = 90
    @sprites["pokemon"].y = 134
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party,@boxsidesviewport)
    if command!=2 # Drop down tab only on Deposit
      @sprites["boxparty"].x = 182
      @sprites["boxparty"].y = Graphics.height
    end
    @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/markings")
    @sprites["markingbg"] = IconSprite.new(292,68,@boxsidesviewport)
    @sprites["markingbg"].setBitmap("Graphics/Pictures/Storage/overlay_marking")
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@boxsidesviewport)
    @sprites["markingoverlay"].visible = false
    pbSetSystemFont(@sprites["markingoverlay"].bitmap)
    @sprites["arrow"] = PokemonBoxArrow.new(@arrowviewport)
    @sprites["arrow"].z += 1
    if command!=2
      pbSetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection)
      pbSetMosaic(@selection)
    else
      pbPartySetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection,@storage.party)
      pbSetMosaic(@selection)
    end
    pbFadeInAndShow(@sprites)
  end

  def pbCloseBox
    pbFadeOutAndHide(@sprites)  
    pbDisposeSpriteHash(@sprites)
    @markingbitmap.dispose if @markingbitmap
    @boxviewport.dispose
    @boxsidesviewport.dispose
    @arrowviewport.dispose
  end

  def pbDisplay(message)
    msgwindow = Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
    msgwindow.viewport       = @viewport
    msgwindow.visible        = true
    msgwindow.letterbyletter = false
    msgwindow.resizeHeightToFit(message,Graphics.width-180)
    msgwindow.text           = message
    pbBottomRight(msgwindow)
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B) || Input.trigger?(Input::C)
        break
      end
      msgwindow.update
      self.update
    end
    msgwindow.dispose
    Input.update
  end

  def pbShowCommands(message,commands,index=0)
    ret = 0
    msgwindow = Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
    msgwindow.viewport       = @viewport
    msgwindow.visible        = true
    msgwindow.letterbyletter = false
    msgwindow.text           = message
    msgwindow.resizeHeightToFit(message,Graphics.width-180)
    pbBottomRight(msgwindow)
    cmdwindow = Window_CommandPokemon.new(commands)
    cmdwindow.viewport = @viewport
    cmdwindow.visible  = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height   = Graphics.height-msgwindow.height if cmdwindow.height>Graphics.height-msgwindow.height
    pbBottomRight(cmdwindow)
    cmdwindow.y        -= msgwindow.height
    cmdwindow.index    = index
    loop do
      Graphics.update
      Input.update
      msgwindow.update
      cmdwindow.update
      if Input.trigger?(Input::B)
        ret = -1
        break
      elsif Input.trigger?(Input::C)
        ret = cmdwindow.index
        break
      end
      self.update
    end
    msgwindow.dispose
    cmdwindow.dispose
    Input.update
    return ret
  end

  def pbSetArrow(arrow,selection)
    case selection
    when -1, -4, -5 # Box name, move left, move right
      arrow.x = 157*2
      arrow.y = -12*2
    when -2 # Party Pokémon
      arrow.x = 119*2
      arrow.y = 139*2
    when -3 # Close Box
      arrow.x = 207*2
      arrow.y = 139*2
    else
      arrow.x = (97+24*(selection%6))*2
      arrow.y = (8+24*(selection/6))*2
    end
  end

  def pbChangeSelection(key,selection)
    case key
    when Input::UP
      if selection==-1 # Box name
        selection = -2
      elsif selection==-2 # Party
        selection = 25
      elsif selection==-3 # Close Box
        selection = 28
      else
        selection -= 6
        selection = -1 if selection<0
      end
    when Input::DOWN
      if selection==-1 # Box name
        selection = 2
      elsif selection==-2 # Party
        selection = -1
      elsif selection==-3 # Close Box
        selection = -1
      else
        selection += 6
        selection = -2 if selection==30 || selection==31 || selection==32
        selection = -3 if selection==33 || selection==34 || selection==35
      end
    when Input::LEFT
      if selection==-1 # Box name
        selection = -4 # Move to previous box
      elsif selection==-2
        selection = -3
      elsif selection==-3
        selection = -2
      else
        selection -= 1
        selection += 6 if selection==-1 || selection%6==5
      end
    when Input::RIGHT
      if selection==-1 # Box name
        selection = -5 # Move to next box
      elsif selection==-2
        selection = -3
      elsif selection==-3
        selection = -2
      else
        selection += 1
        selection -= 6 if selection%6==0
      end
    end
    return selection
  end

  def pbPartySetArrow(arrow,selection)
    if selection>=0
      xvalues = [100,136,100,136,100,136,118]
      yvalues = [1,9,33,41,65,73,110]
      arrow.angle = 0
      arrow.mirror = false
      arrow.ox = 0
      arrow.oy = 0
      arrow.x = xvalues[selection]*2
      arrow.y = yvalues[selection]*2
    end
  end

  def pbPartyChangeSelection(key,selection)
    case key
    when Input::LEFT
      selection -= 1
      selection = 6 if selection<0
    when Input::RIGHT
      selection += 1
      selection = 0 if selection>6
    when Input::UP
      if selection==6
        selection = 5
      else
        selection -= 2
        selection = 6 if selection<0
      end
    when Input::DOWN
      if selection==6
        selection = 0
      else
        selection += 2
        selection = 6 if selection>6
      end
    end
    return selection
  end

  def pbSelectBoxInternal(party)
    selection = @selection
    pbSetArrow(@sprites["arrow"],selection)
    pbUpdateOverlay(selection)
    pbSetMosaic(selection)
    loop do
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key>=0
        pbPlayCursorSE
        selection = pbChangeSelection(key,selection)
        pbSetArrow(@sprites["arrow"],selection)
        if selection==-4
          nextbox = (@storage.currentBox+@storage.maxBoxes-1)%@storage.maxBoxes
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox = nextbox
        elsif selection==-5
          nextbox = (@storage.currentBox+1)%@storage.maxBoxes
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox = nextbox
        end
        selection = -1 if selection==-4 || selection==-5
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      end
      self.update
      if Input.trigger?(Input::L)
        pbPlayCursorSE
        nextbox = (@storage.currentBox+@storage.maxBoxes-1)%@storage.maxBoxes
        pbSwitchBoxToLeft(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::R)
        pbPlayCursorSE
        nextbox = (@storage.currentBox+1)%@storage.maxBoxes
        pbSwitchBoxToRight(nextbox)
        @storage.currentBox = nextbox
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
      elsif Input.trigger?(Input::F5)   # Jump to box name
        if selection!=-1
          pbPlayCursorSE
          selection = -1
          pbSetArrow(@sprites["arrow"],selection)
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        end
      elsif Input.trigger?(Input::A) && @command==0   # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
      elsif Input.trigger?(Input::B)
        @selection = selection
        return nil
      elsif Input.trigger?(Input::C)
        @selection = selection
        if selection>=0
          return [@storage.currentBox,selection]
        elsif selection==-1 # Box name 
          return [-4,-1]
        elsif selection==-2 # Party Pokémon 
          return [-2,-1]
        elsif selection==-3 # Close Box 
          return [-3,-1]
        end
      end
    end
  end

  def pbSelectBox(party)
    return pbSelectBoxInternal(party) if @command==1 # Withdraw
    ret = nil
    loop do
      if !@choseFromParty
        ret = pbSelectBoxInternal(party)
      end
      if @choseFromParty || (ret && ret[0]==-2) # Party Pokémon
        if !@choseFromParty
          pbShowPartyTab
          @selection = 0
        end
        ret = pbSelectPartyInternal(party,false)
        if ret<0
          pbHidePartyTab
          @selection = 0
          @choseFromParty = false
        else
          @choseFromParty = true
          return [-1,ret]
        end
      else
        @choseFromParty = false
        return ret
      end
    end
  end

  def pbSelectPartyInternal(party,depositing)
    selection = @selection
    pbPartySetArrow(@sprites["arrow"],selection)
    pbUpdateOverlay(selection,party)
    pbSetMosaic(selection)
    lastsel = 1
    loop do
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key>=0
        pbPlayCursorSE
        newselection = pbPartyChangeSelection(key,selection)
        if newselection==-1
          return -1 if !depositing
        elsif newselection==-2
          selection = lastsel
        else
          selection = newselection
        end
        pbPartySetArrow(@sprites["arrow"],selection)
        lastsel = selection if selection>0
        pbUpdateOverlay(selection,party)
        pbSetMosaic(selection)
      end
      self.update
      if Input.trigger?(Input::A) && @command==0   # Organize only
        pbPlayDecisionSE
        pbSetQuickSwap(!@quickswap)
      elsif Input.trigger?(Input::B)
        @selection = selection
        return -1
      elsif Input.trigger?(Input::C)
        if selection>=0 && selection<6
          @selection = selection
          return selection
        elsif selection==6   # Close Box 
          @selection = selection
          return (depositing) ? -3 : -1
        end
      end
    end
  end

  def pbSelectParty(party)
    return pbSelectPartyInternal(party,true)
  end

  def pbChangeBackground(wp)
    @sprites["box"].refreshSprites = false
    alpha = 0
    Graphics.update
    self.update
    16.times do
      alpha += 16
      Graphics.update
      Input.update
      @sprites["box"].color = Color.new(248,248,248,alpha)
      self.update
    end
    @sprites["box"].refreshBox = true
    @storage[@storage.currentBox].background = wp
    4.times do
      Graphics.update
      Input.update
      self.update
    end
    16.times do
      alpha -= 16
      Graphics.update
      Input.update
      @sprites["box"].color = Color.new(248,248,248,alpha)
      self.update
    end
    @sprites["box"].refreshSprites = true
  end

  def pbSwitchBoxToRight(newbox)
    newbox = PokemonBoxSprite.new(@storage,newbox,@boxviewport)
    newbox.x = 520
    Graphics.frame_reset
    begin
      Graphics.update
      Input.update
      @sprites["box"].x -= 32
      newbox.x -= 32
      self.update
    end until newbox.x<=184
    diff = newbox.x-184
    newbox.x = 184; @sprites["box"].x -= diff
    @sprites["box"].dispose
    @sprites["box"] = newbox
  end

  def pbSwitchBoxToLeft(newbox)
    newbox = PokemonBoxSprite.new(@storage,newbox,@boxviewport)
    newbox.x = -152
    Graphics.frame_reset
    begin
      Graphics.update
      Input.update
      @sprites["box"].x += 32
      newbox.x += 32
      self.update
    end until newbox.x>=184
    diff = newbox.x-184
    newbox.x = 184; @sprites["box"].x -= diff
    @sprites["box"].dispose
    @sprites["box"] = newbox
  end

  def pbJumpToBox(newbox)
    if @storage.currentBox!=newbox
      if newbox>@storage.currentBox
        pbSwitchBoxToRight(newbox)
      else
        pbSwitchBoxToLeft(newbox)
      end
      @storage.currentBox = newbox
    end
  end

  def pbSetMosaic(selection)
    if !@screen.pbHeldPokemon
      if @boxForMosaic!=@storage.currentBox || @selectionForMosaic!=selection
        @sprites["pokemon"].mosaic = 10
        @boxForMosaic = @storage.currentBox
        @selectionForMosaic = selection
      end
    end
  end

  def pbSetQuickSwap(value)
    @quickswap = value
    @sprites["arrow"].quickswap = value
  end

  def pbShowPartyTab
    begin
      Graphics.update
      Input.update
      @sprites["boxparty"].y -= 24
      self.update
    end until @sprites["boxparty"].y<=Graphics.height-352
    @sprites["boxparty"].y = Graphics.height-352
  end

  def pbHidePartyTab
    begin
      Graphics.update
      Input.update
      @sprites["boxparty"].y += 24
      self.update
    end until @sprites["boxparty"].y>=Graphics.height
    @sprites["boxparty"].y = Graphics.height
  end

  def pbHold(selected)
    if selected[0]==-1
      @sprites["boxparty"].grabPokemon(selected[1],@sprites["arrow"])
    else
      @sprites["box"].grabPokemon(selected[1],@sprites["arrow"])
    end
    while @sprites["arrow"].grabbing?
      Graphics.update
      Input.update
      self.update
    end
  end

  def pbSwap(selected,heldpoke)
    heldpokesprite = @sprites["arrow"].heldPokemon
    boxpokesprite = nil
    if selected[0]==-1
      boxpokesprite = @sprites["boxparty"].getPokemon(selected[1])
    else
      boxpokesprite = @sprites["box"].getPokemon(selected[1])
    end
    if selected[0]==-1
      @sprites["boxparty"].setPokemon(selected[1],heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1],heldpokesprite)
    end
    @sprites["arrow"].setSprite(boxpokesprite)
    @sprites["pokemon"].mosaic = 10
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = selected[1]
  end

  def pbPlace(selected,heldpoke)
    heldpokesprite = @sprites["arrow"].heldPokemon
    @sprites["arrow"].place
    while @sprites["arrow"].placing?
      Graphics.update
      Input.update
      self.update
    end
    if selected[0]==-1
      @sprites["boxparty"].setPokemon(selected[1],heldpokesprite)
    else
      @sprites["box"].setPokemon(selected[1],heldpokesprite)
    end
    @boxForMosaic = @storage.currentBox
    @selectionForMosaic = selected[1]
  end

  def pbWithdraw(selected,heldpoke,partyindex)
    pbHold(selected) if !heldpoke
    pbShowPartyTab
    pbPartySetArrow(@sprites["arrow"],partyindex)
    pbPlace([-1,partyindex],heldpoke)
    pbHidePartyTab
  end

  def pbStore(selected,heldpoke,destbox,firstfree)
    if heldpoke
      if destbox==@storage.currentBox
        heldpokesprite = @sprites["arrow"].heldPokemon
        @sprites["box"].setPokemon(firstfree,heldpokesprite)
        @sprites["arrow"].setSprite(nil)
      else
        @sprites["arrow"].deleteSprite
      end
    else
      sprite = @sprites["boxparty"].getPokemon(selected[1])
      if destbox==@storage.currentBox
        @sprites["box"].setPokemon(firstfree,sprite)
        @sprites["boxparty"].setPokemon(selected[1],nil)
      else
        @sprites["boxparty"].deletePokemon(selected[1])
      end
    end
  end

  def pbRelease(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    if heldpoke
      sprite = @sprites["arrow"].heldPokemon
    elsif box==-1
      sprite = @sprites["boxparty"].getPokemon(index)
    else
      sprite = @sprites["box"].getPokemon(index)
    end
    if sprite
      sprite.release
      while sprite.releasing?
        Graphics.update
        sprite.update
        self.update
      end
    end
  end

  def pbChooseBox(msg)
    commands = []
    for i in 0...@storage.maxBoxes
      box = @storage[i]
      if box
        commands.push(_INTL("{1} ({2}/{3})",box.name,box.nitems,box.length))
      end
    end
    return pbShowCommands(msg,commands,@storage.currentBox)
  end

  def pbBoxName(helptext,minchars,maxchars)
    oldsprites = pbFadeOutAndHide(@sprites)
    ret = pbEnterBoxName(helptext,minchars,maxchars)
    if ret.length>0
      @storage[@storage.currentBox].name = ret
    end
    @sprites["box"].refreshBox = true
    pbRefresh
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbChooseItem(bag)
    ret = 0
    pbFadeOutIn(99999){
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,bag)
      ret = screen.pbChooseItemScreen(Proc.new{|item| pbCanHoldItem?(item) })
    }
    return ret
  end

  def pbSummary(selected,heldpoke)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    if heldpoke
      screen.pbStartScreen([heldpoke],0)
    elsif selected[0]==-1
      @selection = screen.pbStartScreen(@storage.party,selected[1])
      pbPartySetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection,@storage.party)
    else
      @selection = screen.pbStartScreen(@storage.boxes[selected[0]],selected[1])
      pbSetArrow(@sprites["arrow"],@selection)
      pbUpdateOverlay(@selection)
    end
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbMarkingSetArrow(arrow,selection)
    if selection>=0
      xvalues = [162,191,220,162,191,220,184,184]
      yvalues = [24,24,24,49,49,49,77,109]
      arrow.angle = 0
      arrow.mirror = false
      arrow.ox = 0
      arrow.oy = 0
      arrow.x = xvalues[selection]*2
      arrow.y = yvalues[selection]*2
    end
  end

  def pbMarkingChangeSelection(key,selection)
    case key
    when Input::LEFT
      if selection<6
        selection -= 1
        selection += 3 if selection%3==2
      end
    when Input::RIGHT
      if selection<6
        selection += 1
        selection -= 3 if selection%3==0
      end
    when Input::UP
      if selection==7; selection = 6
      elsif selection==6; selection = 4
      elsif selection<3; selection = 7
      else; selection -= 3
      end
    when Input::DOWN
      if selection==7; selection = 1
      elsif selection==6; selection = 7
      elsif selection>=3; selection = 6
      else; selection += 3
      end
    end
    return selection
  end

  def pbMark(selected,heldpoke)
    ret = 0
    @sprites["markingbg"].visible      = true
    @sprites["markingoverlay"].visible = true
    msg = _INTL("Mark your Pokémon.")
    msgwindow = Window_UnformattedTextPokemon.newWithSize("",180,0,Graphics.width-180,32)
    msgwindow.viewport       = @viewport
    msgwindow.visible        = true
    msgwindow.letterbyletter = false
    msgwindow.text           = msg
    msgwindow.resizeHeightToFit(msg,Graphics.width-180)
    pbBottomRight(msgwindow)
    base   = Color.new(248,248,248)
    shadow = Color.new(80,80,80)
    pokemon = heldpoke
    if heldpoke
      pokemon = heldpoke
    elsif selected[0]==-1
      pokemon = @storage.party[selected[1]]
    else
      pokemon = @storage.boxes[selected[0]][selected[1]]
    end
    markings = pokemon.markings
    index = 0
    redraw = true
    markrect = Rect.new(0,0,16,16)
    loop do
      # Redraw the markings and text
      if redraw
        @sprites["markingoverlay"].bitmap.clear
        for i in 0...6
          markrect.x = i*16
          markrect.y = (markings&(1<<i)!=0) ? 16 : 0
          @sprites["markingoverlay"].bitmap.blt(336+58*(i%3),106+50*(i/3),@markingbitmap.bitmap,markrect)
        end
        textpos = [
           [_INTL("OK"),402,210,2,base,shadow,1],
           [_INTL("Cancel"),402,274,2,base,shadow,1]
        ]
        pbDrawTextPositions(@sprites["markingoverlay"].bitmap,textpos)
        pbMarkingSetArrow(@sprites["arrow"],index)
        redraw = false
      end
      Graphics.update
      Input.update
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key>=0
        oldindex = index
        index = pbMarkingChangeSelection(key,index)
        pbPlayCursorSE if index!=oldindex
        pbMarkingSetArrow(@sprites["arrow"],index)
      end
      self.update
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        if index==6 # OK
          pokemon.markings = markings
          break
        elsif index==7 # Cancel
          break
        else
          mask = (1<<index)
          if (markings&mask)==0
            markings |= mask
          else
            markings &= ~mask
          end
          redraw = true
        end
      end
    end
    @sprites["markingbg"].visible      = false
    @sprites["markingoverlay"].visible = false
    msgwindow.dispose
  end

  def pbRefresh
    @sprites["box"].refresh
    @sprites["boxparty"].refresh
  end

  def pbHardRefresh
    oldPartyY = @sprites["boxparty"].y
    @sprites["box"].dispose
    @sprites["box"] = PokemonBoxSprite.new(@storage,@storage.currentBox,@boxviewport)
    @sprites["boxparty"].dispose
    @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party,@boxsidesviewport)
    @sprites["boxparty"].y = oldPartyY
  end
  
  def drawMarkings(bitmap,x,y,width,height,markings)
    markrect = Rect.new(0,0,16,16)
    for i in 0...8
      markrect.x = i*16
      markrect.y = (markings&(1<<i)!=0) ? 16 : 0
      bitmap.blt(x+i*16,y,@markingbitmap.bitmap,markrect)
    end
  end

  def pbUpdateOverlay(selection,party=nil)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    buttonbase = Color.new(248,248,248)
    buttonshadow = Color.new(80,80,80)
    pbDrawTextPositions(overlay,[
       [_INTL("Party: {1}",(@storage.party.length rescue 0)),270,328,2,buttonbase,buttonshadow,1],
       [_INTL("Exit"),446,328,2,buttonbase,buttonshadow,1],
    ])
    pokemon = nil
    if @screen.pbHeldPokemon
      pokemon = @screen.pbHeldPokemon
    elsif selection>=0
      pokemon = (party) ? party[selection] : @storage[@storage.currentBox,selection]
    end
    if !pokemon
      @sprites["pokemon"].visible = false
      return
    end
    @sprites["pokemon"].visible = true
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    nonbase   = Color.new(208,208,208)
    nonshadow = Color.new(224,224,224)
    pokename = pokemon.name
    textstrings = [
       [pokename,10,8,false,base,shadow]
    ]
    if !pokemon.egg?
      imagepos = []
      if pokemon.isMale?
        textstrings.push([_INTL("♂"),148,8,false,Color.new(24,112,216),Color.new(136,168,208)])
      elsif pokemon.isFemale?
        textstrings.push([_INTL("♀"),148,8,false,Color.new(248,56,32),Color.new(224,152,144)])
      end
      imagepos.push(["Graphics/Pictures/Storage/overlay_lv",6,246,0,0,-1,-1])
      textstrings.push([pokemon.level.to_s,28,234,false,base,shadow])
      if pokemon.ability>0
        textstrings.push([PBAbilities.getName(pokemon.ability),86,306,2,base,shadow])
      else
        textstrings.push([_INTL("No ability"),86,306,2,nonbase,nonshadow])
      end
      if pokemon.item>0
        textstrings.push([PBItems.getName(pokemon.item),86,342,2,base,shadow])
      else
        textstrings.push([_INTL("No item"),86,342,2,nonbase,nonshadow])
      end
      if pokemon.isShiny?
        imagepos.push(["Graphics/Pictures/shiny",156,198,0,0,-1,-1])
      end
      typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      type1rect = Rect.new(0,pokemon.type1*28,64,28)
      type2rect = Rect.new(0,pokemon.type2*28,64,28)
      if pokemon.type1==pokemon.type2
        overlay.blt(52,272,typebitmap.bitmap,type1rect)
      else
        overlay.blt(18,272,typebitmap.bitmap,type1rect)
        overlay.blt(88,272,typebitmap.bitmap,type2rect)
      end
      drawMarkings(overlay,70,240,128,20,pokemon.markings)
      pbDrawImagePositions(overlay,imagepos)
    end
    pbDrawTextPositions(overlay,textstrings)
    @sprites["pokemon"].setPokemonBitmap(pokemon)
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end
end



#===============================================================================
# Pokémon storage mechanics
#===============================================================================
class PokemonStorageScreen
  attr_reader :scene
  attr_reader :storage

  def initialize(scene,storage)
    @scene = scene
    @storage = storage
    @pbHeldPokemon = nil
  end

  def pbStartScreen(command)
    @heldpkmn = nil
    if command==0
### MOVE #######################################################################
      @scene.pbStartBox(self,command)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected==nil
          if pbHeldPokemon
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        elsif selected[0]==-3 # Close box
          if pbHeldPokemon
            pbDisplay(_INTL("You're holding a Pokémon!"))
            next
          end
          break if pbConfirm(_INTL("Exit from the Box?"))
          next
        elsif selected[0]==-4 # Box name
          pbBoxCommands
        else
          pokemon = @storage[selected[0],selected[1]]
          heldpoke = pbHeldPokemon
          next if !pokemon && !heldpoke
          if @scene.quickswap
            if @heldpkmn
              (pokemon) ? pbSwap(selected) : pbPlace(selected)
            else
              pbHold(selected)
            end
          else
            commands = []
            cmdMove     = -1
            cmdSummary  = -1
            cmdWithdraw = -1
            cmdItem     = -1
            cmdMark     = -1
            cmdRelease  = -1
            cmdDebug    = -1
            cmdCancel   = -1
            if heldpoke
              helptext = _INTL("{1} is selected.",heldpoke.name)
              commands[cmdMove=commands.length]   = (pokemon) ? _INTL("Shift") : _INTL("Place")
            elsif pokemon
              helptext = _INTL("{1} is selected.",pokemon.name)
              commands[cmdMove=commands.length]   = _INTL("Move")
            end
            commands[cmdSummary=commands.length]  = _INTL("Summary")
            commands[cmdWithdraw=commands.length] = (selected[0]==-1) ? _INTL("Store") : _INTL("Withdraw")
            commands[cmdItem=commands.length]     = _INTL("Item")
            commands[cmdMark=commands.length]     = _INTL("Mark")
            commands[cmdRelease=commands.length]  = _INTL("Release")
            commands[cmdDebug=commands.length]    = _INTL("Debug") if $DEBUG
            commands[cmdCancel=commands.length]   = _INTL("Cancel")
            command=pbShowCommands(helptext,commands)
            if cmdMove>=0 && command==cmdMove   # Move/Shift/Place
              if @heldpkmn
                (pokemon) ? pbSwap(selected) : pbPlace(selected)
              else
                pbHold(selected)
              end
            elsif cmdSummary>=0 && command==cmdSummary   # Summary
              pbSummary(selected,@heldpkmn)
            elsif cmdWithdraw>=0 && command==cmdWithdraw   # Withdraw/Store
              (selected[0]==-1) ? pbStore(selected,@heldpkmn) : pbWithdraw(selected,@heldpkmn)
            elsif cmdItem>=0 && command==cmdItem   # Item
              pbItem(selected,@heldpkmn)
            elsif cmdMark>=0 && command==cmdMark   # Mark
              pbMark(selected,@heldpkmn)
            elsif cmdRelease>=0 && command==cmdRelease   # Release
              pbRelease(selected,@heldpkmn)
            elsif cmdDebug>=0 && command==cmdDebug   # Debug
              pbPokemonDebug((@heldpkmn) ? @heldpkmn : pokemon,selected,heldpoke)
            end
          end
        end
      end
      @scene.pbCloseBox
    elsif command==1
### WITHDRAW ###################################################################
      @scene.pbStartBox(self,command)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected==nil
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        else
          case selected[0]
          when -2 # Party Pokémon
            pbDisplay(_INTL("Which one will you take?"))
            next
          when -3 # Close box
            break if pbConfirm(_INTL("Exit from the Box?"))
            next
          when -4 # Box name
            pbBoxCommands
            next
          end
          pokemon = @storage[selected[0],selected[1]]
          next if !pokemon
          command = pbShowCommands(
             _INTL("{1} is selected.",pokemon.name),[
             _INTL("Withdraw"),
             _INTL("Summary"),
             _INTL("Mark"),
             _INTL("Release"),
             _INTL("Cancel")])
          case command
          when 0 # Withdraw
            pbWithdraw(selected,nil)
          when 1 # Summary
            pbSummary(selected,nil)
          when 2 # Mark
            pbMark(selected,nil)
          when 3 # Release
            pbRelease(selected,nil)
          end
        end
      end
      @scene.pbCloseBox
    elsif command==2
### DEPOSIT ####################################################################
      @scene.pbStartBox(self,command)
      loop do
        selected = @scene.pbSelectParty(@storage.party)
        if selected==-3 # Close box
          break if pbConfirm(_INTL("Exit from the Box?"))
          next
        elsif selected<0
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        else
          pokemon = @storage[-1,selected]
          next if !pokemon
          command = pbShowCommands(
             _INTL("{1} is selected.",pokemon.name),[
             _INTL("Store"),
             _INTL("Summary"),
             _INTL("Mark"),
             _INTL("Release"),
             _INTL("Cancel")])
          case command
          when 0 # Store
            pbStore([-1,selected],nil)
          when 1 # Summary
            pbSummary([-1,selected],nil)
          when 2 # Mark
            pbMark([-1,selected],nil)
          when 3 # Release
            pbRelease([-1,selected],nil)
          end
        end
      end
      @scene.pbCloseBox
    elsif command==3
      @scene.pbStartBox(self,command)
      @scene.pbCloseBox
    end
  end

  def pbHardRefresh   # For debug
    @scene.pbHardRefresh
  end

  def pbRefreshSingle(i)   # For debug
    @scene.pbUpdateOverlay(i[1],(i[0]==-1) ? @storage.party : nil)
    @scene.pbHardRefresh
  end

  def pbDisplay(message)
    @scene.pbDisplay(message)
  end

  def pbConfirm(str)
    return pbShowCommands(str,[_INTL("Yes"),_INTL("No")])==0
  end

  def pbShowCommands(msg,commands,index=0)
    return @scene.pbShowCommands(msg,commands,index)
  end

  def pbAble?(pokemon)
    pokemon && !pokemon.egg? && pokemon.hp>0
  end

  def pbAbleCount
    count = 0
    for p in @storage.party
      count += 1 if pbAble?(p)
    end
    return count
  end

  def pbHeldPokemon
    return @heldpkmn
  end

  def pbWithdraw(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    if box==-1
      raise _INTL("Can't withdraw from party...");
    end
    if @storage.party.nitems>=6
      pbDisplay(_INTL("Your party's full!"))
      return false
    end
    @scene.pbWithdraw(selected,heldpoke,@storage.party.length)
    if heldpoke
      @storage.pbMoveCaughtToParty(heldpoke)
      @heldpkmn = nil
    else
      @storage.pbMove(-1,-1,box,index)
    end
    @scene.pbRefresh
    return true
  end

  def pbStore(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    if box!=-1
      raise _INTL("Can't deposit from box...")
    end   
    if pbAbleCount<=1 && pbAble?(@storage[box,index]) && !heldpoke
      pbDisplay(_INTL("That's your last Pokémon!"))
    elsif heldpoke && heldpoke.mail
      pbDisplay(_INTL("Please remove the Mail."))
    elsif !heldpoke && @storage[box,index].mail
      pbDisplay(_INTL("Please remove the Mail."))
    else
      loop do
        destbox = @scene.pbChooseBox(_INTL("Deposit in which Box?"))
        if destbox>=0
          success = false
          firstfree = @storage.pbFirstFreePos(destbox)
          if firstfree<0
            pbDisplay(_INTL("The Box is full."))
            next
          end
          @scene.pbStore(selected,heldpoke,destbox,firstfree)
          if heldpoke
            @storage.pbMoveCaughtToBox(heldpoke,destbox)
            @heldpkmn = nil
          else
            @storage.pbMove(destbox,-1,-1,index)
          end
        end
        break
      end
      @scene.pbRefresh
    end
  end

  def pbHold(selected)
    box = selected[0]
    index = selected[1]
    if box==-1 && pbAble?(@storage[box,index]) && pbAbleCount<=1
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    @scene.pbHold(selected)
    @heldpkmn = @storage[box,index]
    @storage.pbDelete(box,index) 
    @scene.pbRefresh
  end

  def pbPlace(selected)
    box = selected[0]
    index = selected[1]
    if @storage[box,index]
      raise _INTL("Position {1},{2} is not empty...",box,index)
    end
    if box!=-1 && index>=@storage.maxPokemon(box)
      pbDisplay("Can't place that there.")
      return
    end
    if box!=-1 && @heldpkmn.mail
      pbDisplay("Please remove the mail.")
      return
    end
    if box>=0
      @heldpkmn.heal
      @heldpkmn.formTime = nil if @heldpkmn.respond_to?("formTime") && @heldpkmn.formTime
    end
    @scene.pbPlace(selected,@heldpkmn)
    @storage[box,index] = @heldpkmn
    if box==-1
      @storage.party.compact!
    end
    @scene.pbRefresh
    @heldpkmn = nil
  end

  def pbSwap(selected)
    box = selected[0]
    index = selected[1]
    if !@storage[box,index]
      raise _INTL("Position {1},{2} is empty...",box,index)
    end
    if box==-1 && pbAble?(@storage[box,index]) && pbAbleCount<=1 && !pbAble?(@heldpkmn)
      pbDisplay(_INTL("That's your last Pokémon!"))
      return false
    end
    if box!=-1 && @heldpkmn.mail
      pbDisplay("Please remove the mail.")
      return false
    end
    @scene.pbSwap(selected,@heldpkmn)
    if box>=0
      @heldpkmn.heal
      @heldpkmn.formTime = nil if @heldpkmn.respond_to?("formTime") && @heldpkmn.formTime
    end
    tmp = @storage[box,index]
    @storage[box,index] = @heldpkmn
    @heldpkmn = tmp
    @scene.pbRefresh
    return true
  end

  def pbRelease(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    pokemon = (heldpoke) ? heldpoke : @storage[box,index]
    return if !pokemon
    if pokemon.egg?
      pbDisplay(_INTL("You can't release an Egg."))
      return false
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return false
    end
    if box==-1 && pbAbleCount<=1 && pbAble?(pokemon) && !heldpoke
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    command = pbShowCommands(_INTL("Release this Pokémon?"),[_INTL("No"),_INTL("Yes")])
    if command==1
      pkmnname = pokemon.name
      @scene.pbRelease(selected,heldpoke)
      if heldpoke
        @heldpkmn = nil
      else
        @storage.pbDelete(box,index)
      end
      @scene.pbRefresh
      pbDisplay(_INTL("{1} was released.",pkmnname))
      pbDisplay(_INTL("Bye-bye, {1}!",pkmnname))
      @scene.pbRefresh
    end
    return
  end

  def pbChooseMove(pkmn,helptext,index=0)
    movenames = []
    for i in pkmn.moves
      break if i.id==0
      if i.totalpp==0
        movenames.push(_INTL("{1} (PP: ---)",PBMoves.getName(i.id),i.pp,i.totalpp))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})",PBMoves.getName(i.id),i.pp,i.totalpp))
      end
    end
    return @scene.pbShowCommands(helptext,movenames,index)
  end

  def pbSummary(selected,heldpoke)
    @scene.pbSummary(selected,heldpoke)
  end

  def pbMark(selected,heldpoke)
    @scene.pbMark(selected,heldpoke)
  end

  def pbItem(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    pokemon = (heldpoke) ? heldpoke : @storage[box,index]
    if pokemon.egg?
      pbDisplay(_INTL("Eggs can't hold items."))
      return
    elsif pokemon.mail
      pbDisplay(_INTL("Please remove the mail."))
      return
    end
    if pokemon.item>0
      itemname = PBItems.getName(pokemon.item)
      if pbConfirm(_INTL("Take this {1}?",itemname))
        if !$PokemonBag.pbStoreItem(pokemon.item)
          pbDisplay(_INTL("Can't store the {1}.",itemname))
        else
          pbDisplay(_INTL("Took the {1}.",itemname))
          pokemon.setItem(0)
          @scene.pbHardRefresh
        end
      end
    else
      item = scene.pbChooseItem($PokemonBag)
      if item>0
        itemname = PBItems.getName(item)
        pokemon.setItem(item)
        $PokemonBag.pbDeleteItem(item)
        pbDisplay(_INTL("{1} is now being held.",itemname))
        @scene.pbHardRefresh
      end
    end
  end

  def pbBoxCommands
    commands = [
       _INTL("Jump"),
       _INTL("Wallpaper"),
       _INTL("Name"),
       _INTL("Cancel"),
    ]
    command = pbShowCommands(
       _INTL("What do you want to do?"),commands)
    case command
    when 0
      destbox = @scene.pbChooseBox(_INTL("Jump to which Box?"))
      if destbox>=0
        @scene.pbJumpToBox(destbox)
      end
    when 1
      papers = @storage.availableWallpapers
      index = 0
      for i in 0...papers[1].length
        if papers[1][i]==@storage[@storage.currentBox].background
          index = i; break
        end
      end
      wpaper = pbShowCommands(_INTL("Pick the wallpaper."),papers[0],index)
      if wpaper>=0
        @scene.pbChangeBackground(papers[1][wpaper])
      end
    when 2
      @scene.pbBoxName(_INTL("Box name?"),0,12)
    end
  end

  def pbChoosePokemon(party=nil)
    @heldpkmn = nil
    @scene.pbStartBox(self,2)
    retval = nil
    loop do
      selected = @scene.pbSelectBox(@storage.party)
      if selected && selected[0]==-3 # Close box
        break if pbConfirm(_INTL("Exit from the Box?"))
        next
      end
      if selected==nil
        next if pbConfirm(_INTL("Continue Box operations?"))
        break
      elsif selected[0]==-4 # Box name
        pbBoxCommands
      else
        pokemon = @storage[selected[0],selected[1]]
        next if !pokemon
        commands = [
           _INTL("Select"),
           _INTL("Summary"),
           _INTL("Withdraw"),
           _INTL("Item"),
           _INTL("Mark")
        ]
        commands.push(_INTL("Cancel"))
        commands[2] = _INTL("Store") if selected[0]==-1
        helptext = _INTL("{1} is selected.",pokemon.name)
        command = pbShowCommands(helptext,commands)
        case command
        when 0 # Move/Shift/Place
          if pokemon
            retval = selected
            break
          end
        when 1 # Summary
          pbSummary(selected,nil)
        when 2 # Withdraw
          if selected[0]==-1
            pbStore(selected,nil)
          else
            pbWithdraw(selected,nil)
          end
        when 3 # Item
          pbItem(selected,nil)
        when 4 # Mark
          pbMark(selected,nil)
        end
      end
    end
    @scene.pbCloseBox
    return retval
  end
end