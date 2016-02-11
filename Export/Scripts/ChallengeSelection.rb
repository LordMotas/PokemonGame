class ChallengeSelection
    
  def initialize
    @resizeX=Graphics.width/720.0
    @resizeY=Graphics.height/480.0
    @sprites={}
    @buttonSpritesMain={}
    @descriptionSprite={}
    @buttonSprites1={}
    @buttonSprites2={}
    @buttonSprites3={}
    @viewport1=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport1.z=99997
    @viewport2=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport2.z=99998
    @viewport3=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport3.z=99999
    @path="Graphics/Pictures/Challenge Modes/"
    #Background
    @sprites["bg"]=Sprite.new(@viewport1)
    @sprites["bg"].bitmap=Bitmap.new(@path+"bg")
    @sprites["bg"].zoom_x=Graphics.width/720.0
    @sprites["bg"].zoom_y=Graphics.height/480.0
    @sprites["bg_top"]=Sprite.new(@viewport3)
    @sprites["bg_top"].bitmap=Bitmap.new(@path+"bg_top")
    @sprites["bg_top"].zoom_x=Graphics.width/720.0
    @sprites["bg_top"].zoom_y=Graphics.height/480.0
    
    #Push text for each challenge, to be displayed under selected
    @curSelected=[]
    
    #Text for Main Buttons
    #Randomized not currently implemented
    #[Mode title, description, has options]
    @buttonMainText=[
        [_INTL("Nuzlocke"),_INTL("Popular challenge mode in which you cannot use fainted Pokemon, and catching is limited."),true],
        [_INTL("No Running"),_INTL("You cannot run away from wild battles."),false],
        [_INTL("Randomize"),_INTL("Encounters and/or trainers have randomized Pokemon"),true],
        [_INTL("No Evolutions"),_INTL("Your Pokemon cannot evolve."),false],
        [_INTL("Solo Run"),_INTL("You can only use your starter."),false],
        [_INTL("Inverse Locke"),_INTL("All battles are inverse battles (type effectiveness is reversed in battle)"),false],
        [_INTL("No Items"),_INTL("You cannot use any items, in field or in battle"),false],
        [_INTL("No TMs"),_INTL("Your Pokemon cannot learn moves via TMs."),false]
        ]
    #Clauses for each challenge
    #[Clause title, description, has more specific subclauses]
    @nuzlockeSelected=[]
    @nuzlockeClauses=[
      [ _INTL("Dubious Clause"),
        _INTL("Encounters of an already caught species do not count towards encounters"),
        false
      ],
      [ _INTL("PP Clause"),
        _INTL("PokeCenters do not heal PP."),
        true
      ],
      [ _INTL("Encounter Tokens"),
        _INTL("Get Encounter Tokens to get additional encounters after significant events."),
        true
      ],
      [ _INTL("Revive Tokens"),
        _INTL("Get Revive Tokens to revive a fainted Pokemon after significant events."),
        true
      ],
      [ _INTL("Shiny Clause"),
        _INTL("Shiny Pokemon do not count towards encounters unless you catch them."),
        false
      ]
    ]
    #PP subclauses
    @PPClausesSelected=[]
    @PPSubClauses =
    [
      [ 
        _INTL("No PP Items"),
        _INTL("PP Items will not work.")
      ],
      [
        _INTL("PP Token"),
        _INTL("Gain a PP Token after each gym victory")
      ]
    ]
    
    @catchTokensSelected=[]
    @catchTokenSubClauses =
    [
      [
        _INTL("After Gift"),
        _INTL("Recieve encounter token instead of getting a gift pokemon (excludes starter).")
      ],
      [
        _INTL("After Gym"),
        _INTL("Recieve encounter token after defeating a gym.")
      ]
    ]
    
    @encounterTokensSelected=[]
    @encounterTokenSubClauses =
    [
      [
        _INTL("After Gift"),
        _INTL("Recieve encounter token instead of getting a gift pokemon (excludes starter).")
      ],
      [
        _INTL("After Gym"),
        _INTL("Recieve encounter token after defeating a gym.")
      ]
    ]
    
    @reviveTokensSelected=[]
    @reviveTokenSubClauses =
    [
      [
        _INTL("After Gift"),
        _INTL("Recieve revive token instead of getting a gift pokemon (excludes starter).")
      ],
      [
        _INTL("After Gym"),
        _INTL("Recieve revive token after defeating a gym.")
      ]
    ]
    
    @randomizedSelected=[]
    @randomizedClauses=[
      [ _INTL("Randomized Battles"),
        _INTL("Both wild and trainer battles are randomized."),
        true
      ],
      [ _INTL("Randomized Gifts"),
        _INTL("Pokemon given to you are randomized."),
        true
      ],
      [ _INTL("Randomized Events"),
        _INTL("Event encounters are randomized."),
        true
      ],
      [ _INTL("Randomized Items"),
        _INTL("Non-essential items are randomized."),
        false
      ],
      [ _INTL("Randomized Moves"),
        _INTL("All Pokemon's learnsets are randomized."),
        false
      ],
      [ _INTL("Randomized Abilities"),
        _INTL("Pokemon's abilities are randomized"),
        false
      ]
    ]
    
    @randomPokemonSubClausesSelected=[]
    @randomPokemonSubClauses=[
      [
        _INTL("Pure Random"),
        _INTL("Every generated Pokemon is randomized individually, rather than at the start.")
      ],
      [
        _INTL("Set Random"),
        _INTL("Encounters, trainers, etc are randomized at the beginning of the playthrough. If a trainer is randomized to have a Pidgey, they will have that Poliweed even if you battle them again.")
      ],
      [
        _INTL("Set Psuedo-Random"),
        _INTL("Encounters, trainers, etc are randomized at the beginning of the playthrough, but are randomized to a pokemon with similar BST.")
      ]
    ]
    
    @randomPokemonGiftSelected=[]
    @randomPokemonGiftClauses=[
      [
        _INTL("Pure Random"),
        _INTL("Every generated Pokemon is randomized individually, rather than at the start.")
      ],
      [
        _INTL("Set Random"),
        _INTL("Encounters, trainers, etc are randomized at the beginning of the playthrough. If a trainer is randomized to have a Pidgey, they will have that Poliweed even if you battle them again.")
      ],
      [
        _INTL("Set Psuedo-Random"),
        _INTL("Encounters, trainers, etc are randomized at the beginning of the playthrough, but are randomized to a pokemon with similar BST.")
      ]
    ]
    
    @randomEventPokemonSelected=[]
    @randomEventPokemonClauses=[
      [
        _INTL("Pure Random"),
        _INTL("Every generated Pokemon is randomized individually, rather than at the start.")
      ],
      [
        _INTL("Set Random"),
        _INTL("Encounters, trainers, etc are randomized at the beginning of the playthrough. If a trainer is randomized to have a Pidgey, they will have that Poliweed even if you battle them again.")
      ],
      [
        _INTL("Set Psuedo-Random"),
        _INTL("Encounters, trainers, etc are randomized at the beginning of the playthrough, but are randomized to a pokemon with similar BST.")
      ]
    ]
    
    #Holds all clauses for page 2 and 3
    @page2Clauses = 
    [ 
      [_INTL("Nuzlocke Clauses"),@nuzlockeClauses],
      ["",nil],
      [_INTL("Randomizer Choices"),@randomizedClauses],
      ["",nil],
      ["",nil],
      ["",nil],
      ["",nil],
      ["",nil]
    ]
    
    #Holds subclauses
    @page3Clauses = 
    [
      #nuzlocke clauses
      [
        ["",nil],
        [_INTL("PP SubClauses"),@PPSubClauses,_INTL("Check all that apply"),true],
        [_INTL("Catch Tokens"),@catchTokenSubClauses,_INTL("Check all that apply"),true],
        [_INTL("Encounter Tokens"),@encounterTokenSubClauses,_INTL("Check all that apply"),true],
        [_INTL("Revive Tokens"),@reviveTokenSubClauses,_INTL("Choose one"),false],
        ["",nil]
      ],
      #no running
      [
      ],
      #randomize
      [
        [_INTL("Randomized Battle Options"),@randomPokemonSubClauses,_INTL("Choose One"),false],
        [_INTL("Randomized Gift Pokemon Options"),@randomPokemonGiftClauses,_INTL("Choose One"),false],
        [_INTL("Randomized Event Pokemon Options"),@randomEventPokemonClauses,_INTL("Choose One"),false],
        ["",nil],
        ["",nil],
        ["",nil]        
      ],
      #no evolution
      [
      ],
      #solo run
      [
      ],
      #inverse
      [
      ],
      #no items
      [
      ],
      #no tms
      [
      ]
    ]
    
    @mainSelectX=0
    @mainSelectY=0
    
    @page2SelectY=0
    @page2SelectX=0
    
    @page3SelectY=0
    
    pbSetUpButtons1
    pbUpdateButtons1
    pbRun1
    pbEndScene
  end
  
################################################################################
#               Main Page
################################################################################

  def pbSetUpButtons1
    pbDisposeSpriteHash(@buttonSpritesMain)
    pbDisposeSpriteHash(@buttonSprites1)
    pbDisposeSpriteHash(@descriptionSprite)
    #Make Buttons
    @buttonSpritesMain={}
    @buttonSprites1={}
    @descriptionSprite={}
    for i in 0...@buttonMainText.length
      @buttonSprites1["main_button_#{i}"]=Sprite.new(@viewport2)
      @buttonSprites1["main_button_#{i}"].bitmap=Bitmap.new(@path+"button_op")
      @buttonSprites1["main_button_#{i}"].src_rect=Rect.new(0,0,257,87)
      @buttonSprites1["main_button_#{i}"].x=180*@resizeX
      @buttonSprites1["main_button_#{i}"].y=125*@resizeY+110*i*@resizeY
      @buttonSprites1["main_button_#{i}"].zoom_x=@resizeX
      @buttonSprites1["main_button_#{i}"].zoom_y=Graphics.height/480.0
      if @buttonMainText[i][2]
        @buttonSprites1["pref_button_#{i}"]=Sprite.new(@viewport2)
        @buttonSprites1["pref_button_#{i}"].bitmap=Bitmap.new(@path+"button_pref")
        @buttonSprites1["pref_button_#{i}"].x=460*@resizeX
        @buttonSprites1["pref_button_#{i}"].y=125*@resizeY+110*i*@resizeY
        @buttonSprites1["pref_button_#{i}"].src_rect=Rect.new(0,0,222,87)
        @buttonSprites1["pref_button_#{i}"].zoom_x=@resizeX
        @buttonSprites1["pref_button_#{i}"].zoom_y=@resizeY
      end
    end
    
    #Button text
    @buttonSprites1["button_text"]=Sprite.new(@viewport2)
    @buttonSprites1["button_text"].bitmap.clear if @buttonSprites1["button_text"].bitmap
    @buttonSprites1["button_text"].bitmap=Bitmap.new(Graphics.width,Graphics.height*10)
    textpos=[]
    pbSetDSIFont(@buttonSprites1["button_text"].bitmap)
    @buttonSprites1["button_text"].bitmap.font.size=36
    textColor=Color.new(255,255,255)
    outlineColor=Color.new(0,0,0)
    for i in 0...@buttonMainText.length
      textpos.push([@buttonMainText[i][0],312*@resizeX,145*@resizeY+110*i*@resizeY,2,textColor,outlineColor])
      if @buttonMainText[i][2]
        textpos.push([_INTL("Set"),574*@resizeX,127*@resizeY+110*i*@resizeY,2,textColor,outlineColor])
        textpos.push([_INTL("Preferences"),574*@resizeX,156*@resizeY+110*i*@resizeY,2,textColor,outlineColor])
      end
    end
    pbDrawTextPositions(@buttonSprites1["button_text"].bitmap,textpos)
    
    #Main text
    @buttonSpritesMain["main_text"]=Sprite.new(@viewport3)
    @buttonSpritesMain["main_text"].bitmap.clear if @buttonSpritesMain["main_text"].bitmap
    @buttonSpritesMain["main_text"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    pbSetDSIFont(@buttonSpritesMain["main_text"].bitmap)
    textpos=[]
    textColor=Color.new(0,0,0)
    outlineColor=Color.new(55,55,55)
    @buttonSpritesMain["main_text"].bitmap.font.size=(56*@resizeY).floor
    textpos.push([_INTL("Challenge Modes"),Graphics.width/2,25*@resizeY,2,textColor,outlineColor])
    pbDrawTextPositions(@buttonSpritesMain["main_text"].bitmap,textpos)
    textpos=[]
    @buttonSpritesMain["main_text"].bitmap.font.size=(42*@resizeY).floor
    textpos.push([_INTL("Selected"),80*@resizeX,95*@resizeY-(10/@resizeY),2,textColor,outlineColor])
    pbDrawTextPositions(@buttonSpritesMain["main_text"].bitmap,textpos)
    textpos=[]
    @buttonSpritesMain["main_text"].bitmap.font.size=32
    if @curSelected.length>0
      for i in 0...@curSelected.length
        textpos.push([_INTL(@curSelected[i]),80*@resizeX,150*@resizeY+40*i*@resizeY,2,textColor,outlineColor])
      end
    end
    pbDrawTextPositions(@buttonSpritesMain["main_text"].bitmap,textpos)
    #description text
    textpos=[]
    textColor=Color.new(255,255,255)
    outlineColor=Color.new(0,0,0)
    @descriptionSprite["desc_text"]=Sprite.new(@viewport3)
    @descriptionSprite["desc_text"].bitmap.clear if @descriptionSprite["desc_text"].bitmap
    @descriptionSprite["desc_text"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    drawTextEx(@descriptionSprite["desc_text"].bitmap,
         180*@resizeX,380*@resizeY,Graphics.width-180*@resizeX,3,@buttonMainText[@mainSelectY][1],textColor,outlineColor)
  end
  
  def pbRun1
    loop do
      Graphics.update
      Input.update
      #break if Input.trigger?(Input::B)
      if Input.trigger?(Input::C)
        if @mainSelectX==0 #Add to selection
          pbUpdateModes
          pbSetUpButtons1
          (@mainSelectY).times do
            @buttonSprites1.each do |key, value|
              @buttonSprites1[key].y-=87*@resizeY
            end
          end
          pbUpdateButtons1
          Graphics.update
        else #Go to preferences
          #Add to selected
          if !@curSelected.include?(@buttonMainText[@mainSelectY][0])
            @curSelected.push(@buttonMainText[@mainSelectY][0])
          end
          @page2SelectY=0
          @page2SelectX=0
          pbSetUpButtons2
          for i in 1..33
            @buttonSprites2.each do |key, value|
              @buttonSprites2[key].x+=i*@resizeX
            end
          end
          pbTransition1
          pbRun2
          pbSetUpButtons1
          pbUpdateButtons1
          for i in 1..33
            @buttonSprites1.each do |key, value|
              @buttonSprites1[key].x-=i*@resizeX
            end
          end
          (@mainSelectY).times do
            @buttonSprites1.each do |key, value|
              @buttonSprites1[key].y-=87*@resizeY
            end
          end
          pbTransition2 #go back to main page
          Input.update
          Graphics.update
        end
      end
      if Input.trigger?(Input::A)
        if Kernel.pbConfirmMessage(_INTL("Are you sure you want these options?"))
          break
        end
      end
      if Input.trigger?(Input::DOWN) && @mainSelectY<(@buttonMainText.length-1)
        @buttonSprites1.each do |key, value|
          @buttonSprites1[key].y-=87*@resizeY
        end
        @mainSelectY+=1
        @mainSelectX=0 if !@buttonSprites1["pref_button_#{@mainSelectY}"]
        pbUpdateButtons1
        Graphics.update
      end
      if Input.trigger?(Input::UP) && @mainSelectY>0
        @buttonSprites1.each do |key, value|
          @buttonSprites1[key].y+=87*@resizeY
        end
        @mainSelectY-=1
        @mainSelectX=0 if !@buttonSprites1["pref_button_#{@mainSelectY}"]
        pbUpdateButtons1
        Graphics.update
      end
      if Input.trigger?(Input::RIGHT) && @mainSelectX==0 && @buttonSprites1["pref_button_#{@mainSelectY}"]
        @mainSelectX=1
        pbUpdateButtons1
        Graphics.update
      end
      if Input.trigger?(Input::LEFT) && @mainSelectX==1 && @buttonSprites1["pref_button_#{@mainSelectY}"]
        @mainSelectX=0
        pbUpdateButtons1
        Graphics.update
      end
    end
    Input.update
  end
  
  def pbUpdateButtons1
    for i in 0...@buttonMainText.length
      if i==@mainSelectY
        if @mainSelectX==0
          @buttonSprites1["main_button_#{i}"].src_rect=Rect.new(257,0,257,87)
          @buttonSprites1["pref_button_#{i}"].src_rect=Rect.new(0,0,222,87) if @buttonMainText[i][2]
        else
          @buttonSprites1["main_button_#{i}"].src_rect=Rect.new(0,0,257,87)
          @buttonSprites1["pref_button_#{i}"].src_rect=Rect.new(222,0,222,87) if @buttonMainText[i][2]
        end
      else
       @buttonSprites1["main_button_#{i}"].src_rect=Rect.new(0,0,257,87)
       @buttonSprites1["pref_button_#{i}"].src_rect=Rect.new(0,0,222,87) if @buttonMainText[i][2]
      end
    end
    pbDisposeSpriteHash(@descriptionSprite)
    @descriptionSprite={}
    textpos=[]
    textColor=Color.new(255,255,255)
    outlineColor=Color.new(0,0,0)
    @descriptionSprite["desc_text"]=Sprite.new(@viewport3)
    @descriptionSprite["desc_text"].bitmap.clear if @descriptionSprite["desc_text"].bitmap
    @descriptionSprite["desc_text"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    drawTextEx(@descriptionSprite["desc_text"].bitmap,
         180*@resizeX,380*@resizeY,Graphics.width-180*@resizeX,3,@buttonMainText[@mainSelectY][1],textColor,outlineColor)
  end
  
  def pbDisposeButtons1
    pbDisposeSpriteHash(@buttonSprites1)
    Graphics.update
  end
  
  def pbUpdateModes
    if @curSelected.include?(@buttonMainText[@mainSelectY][0])
      @curSelected.delete(@buttonMainText[@mainSelectY][0])
    else
      @curSelected.push(@buttonMainText[@mainSelectY][0])
    end
  end
  
  #From page one to two
  def pbTransition1
    #Move buttons to the left
    for i in 1..33
      @buttonSprites1.each do |key, value|
        @buttonSprites1[key].x-=i*@resizeX
      end
      @buttonSprites2.each do |key, value|
        @buttonSprites2[key].x-=i*@resizeX
      end
      Graphics.update
    end
  end
  
################################################################################
#                             Second Page
################################################################################
  
  def pbSetUpButtons2
    pbDisposeSpriteHash(@buttonSpritesMain)
    pbDisposeSpriteHash(@buttonSprites2)
    pageTitle = @page2Clauses[@mainSelectY][0]
    for i in 0...@page2Clauses[@mainSelectY][1].length
      @buttonSprites2["clause_#{i}"]=Sprite.new(@viewport2)
      @buttonSprites2["clause_#{i}"].bitmap=Bitmap.new(@path+"button_op")
      @buttonSprites2["clause_#{i}"].src_rect=Rect.new(0,0,257,87)
      @buttonSprites2["clause_#{i}"].x=180*@resizeX
      @buttonSprites2["clause_#{i}"].y=125*@resizeY+110*i*@resizeY
      @buttonSprites2["clause_#{i}"].zoom_x=@resizeX
      @buttonSprites2["clause_#{i}"].zoom_y=@resizeY
      if @page2Clauses[@mainSelectY][1][i][2]
        @buttonSprites2["clause_pref_button_#{i}"]=Sprite.new(@viewport2)
        @buttonSprites2["clause_pref_button_#{i}"].bitmap=Bitmap.new(@path+"button_pref")
        @buttonSprites2["clause_pref_button_#{i}"].x=460*@resizeX
        @buttonSprites2["clause_pref_button_#{i}"].y=125*@resizeY+110*i*@resizeY
        @buttonSprites2["clause_pref_button_#{i}"].src_rect=Rect.new(0,0,222,87)
        @buttonSprites2["clause_pref_button_#{i}"].zoom_x=@resizeX
        @buttonSprites2["clause_pref_button_#{i}"].zoom_y=@resizeY
      end
    end
    #Button text
    @buttonSprites2["button_text"]=Sprite.new(@viewport2)
    @buttonSprites2["button_text"].bitmap.clear if @buttonSprites2["button_text"].bitmap
    @buttonSprites2["button_text"].bitmap=Bitmap.new(Graphics.width,Graphics.height*10)
    textpos=[]
    pbSetDSIFont(@buttonSprites2["button_text"].bitmap)
    @buttonSprites2["button_text"].bitmap.font.size=36
    textColor=Color.new(255,255,255)
    outlineColor=Color.new(0,0,0)
    for i in 0...@page2Clauses[@mainSelectY][1].length
      textpos.push([@page2Clauses[@mainSelectY][1][i][0],312*@resizeX,145*@resizeY+110*i*@resizeY,2,textColor,outlineColor])
      if @page2Clauses[@mainSelectY][1][i][2]
        textpos.push([_INTL("Set"),574*@resizeX,127*@resizeY+110*i*@resizeY,2,textColor,outlineColor])
        textpos.push([_INTL("Preferences"),574*@resizeX,156*@resizeY+110*i*@resizeY,2,textColor,outlineColor])
      end
    end
    pbDrawTextPositions(@buttonSprites2["button_text"].bitmap,textpos)
    
    #Main text
    @buttonSpritesMain["main_text"]=Sprite.new(@viewport3)
    @buttonSpritesMain["main_text"].bitmap.clear if @buttonSpritesMain["main_text"].bitmap
    @buttonSpritesMain["main_text"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    pbSetDSIFont(@buttonSpritesMain["main_text"].bitmap)
    textpos=[]
    textColor=Color.new(0,0,0)
    outlineColor=Color.new(55,55,55)
    @buttonSpritesMain["main_text"].bitmap.font.size=(56*@resizeY).floor
    textpos.push([_INTL("#{pageTitle}"),Graphics.width/2,25*@resizeY,2,textColor,outlineColor])
    pbDrawTextPositions(@buttonSpritesMain["main_text"].bitmap,textpos)
    textpos=[]
    @buttonSpritesMain["main_text"].bitmap.font.size=(42*@resizeY).floor
    textpos.push([_INTL("Selected"),80*@resizeX,95*@resizeY-(10/@resizeY),2,textColor,outlineColor])
    pbDrawTextPositions(@buttonSpritesMain["main_text"].bitmap,textpos)
    textpos=[]
    @buttonSpritesMain["main_text"].bitmap.font.size=32
    case @page2Clauses[@mainSelectY][0]
    when _INTL("Nuzlocke Clauses")
      if @nuzlockeSelected.length>0
        for i in 0...@nuzlockeSelected.length
          textpos.push([_INTL(@nuzlockeSelected[i]),80*@resizeX,150*@resizeY+40*i*@resizeY,2,textColor,outlineColor])
        end
      end
    when _INTL("Randomizer Choices")
      if @randomizedSelected.length>0
        for i in 0...@randomizedSelected.length
          textpos.push([_INTL(@randomizedSelected[i]),80*@resizeX,150*@resizeY+40*i*@resizeY,2,textColor,outlineColor])
        end
      end
    end
    pbDrawTextPositions(@buttonSpritesMain["main_text"].bitmap,textpos)
  end
  
  def pbRun2
    pbUpdateButtons2
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::C)
        if @page2SelectX==0 #Add to selection
          pbUpdateModes2
          pbSetUpButtons2
          @page2SelectY.times do
            @buttonSprites2.each do |key, value|
              @buttonSprites2[key].y-=87*@resizeY
            end
          end
          pbUpdateButtons2
          Graphics.update
        else #Go to preferences (page 3)
          case @page2Clauses[@mainSelectY][0]
          when _INTL("Nuzlocke Clauses")
            if !@nuzlockeSelected.include?(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
              @nuzlockeSelected.push(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
            end
          when _INTL("Randomizer Choices")
            if @randomizedSelected.length>0
              for i in 0...@randomizedSelected.length
                if !@randomizedSelected.include?(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
                  @randomizedSelected.push(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
                end
              end
            else
              @randomizedSelected.push(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
            end
          #when other clauses
          end
          @page3SelectY=0
          @page3SelectX=0
          pbSetUpButtons3
          for i in 1..33
            @buttonSprites3.each do |key, value|
              @buttonSprites3[key].x+=i*@resizeX
            end
          end
          pbTransition3
          pbRun3
          pbSetUpButtons2
          pbUpdateButtons2
          for i in 1..33
            @buttonSprites2.each do |key, value|
              @buttonSprites2[key].x-=i*@resizeX
            end
          end
          (@page2SelectY).times do
            @buttonSprites2.each do |key, value|
              @buttonSprites2[key].y-=87*@resizeY
            end
          end
          pbTransition4 #go back to second page
          Input.update
          Graphics.update
        end
      end
      break if Input.trigger?(Input::B)
      if Input.trigger?(Input::DOWN) && @page2SelectY<(@page2Clauses[@mainSelectY][1].length-1)
        @buttonSprites2.each do |key, value|
          @buttonSprites2[key].y-=87*@resizeY
        end
        @page2SelectY+=1
        @page2SelectX=0 if !@buttonSprites2["clause_pref_button_#{@page2SelectY}"]
        pbUpdateButtons2
        Graphics.update
      end
      if Input.trigger?(Input::UP) && @page2SelectY>0
        @buttonSprites2.each do |key, value|
          @buttonSprites2[key].y+=87*@resizeY
        end
        @page2SelectY-=1
        @page2SelectX=0 if !@buttonSprites2["clause_pref_button_#{@page2SelectY}"]
        pbUpdateButtons2
        Graphics.update
      end
      if Input.trigger?(Input::RIGHT) && @page2SelectX==0 && @buttonSprites2["clause_pref_button_#{@page2SelectY}"]
        @page2SelectX=1
        pbUpdateButtons2
        Graphics.update
      end
      if Input.trigger?(Input::LEFT) && @page2SelectX==1
        @page2SelectX=0
        pbUpdateButtons2
        Graphics.update
      end
    end
  end
  
  def pbUpdateButtons2
     for i in 0...@page2Clauses[@mainSelectY][1].length
      if i==@page2SelectY
        if @page2SelectX==0
          @buttonSprites2["clause_#{i}"].src_rect=Rect.new(257,0,257,87)
          @buttonSprites2["clause_pref_button_#{i}"].src_rect=Rect.new(0,0,222,87) if @page2Clauses[@mainSelectY][1][i][2]
        else
          @buttonSprites2["clause_#{i}"].src_rect=Rect.new(0,0,257,87)
          @buttonSprites2["clause_pref_button_#{i}"].src_rect=Rect.new(222,0,222,87) if @page2Clauses[@mainSelectY][1][i][2]
        end
      else
       @buttonSprites2["clause_#{i}"].src_rect=Rect.new(0,0,257,87)
       @buttonSprites2["clause_pref_button_#{i}"].src_rect=Rect.new(0,0,222,87) if @page2Clauses[@mainSelectY][1][i][2]
      end
    end
    pbDisposeSpriteHash(@descriptionSprite)
    @descriptionSprite={}
    textpos=[]
    textColor=Color.new(255,255,255)
    outlineColor=Color.new(0,0,0)
    @descriptionSprite["desc_text"]=Sprite.new(@viewport3)
    @descriptionSprite["desc_text"].bitmap.clear if @descriptionSprite["desc_text"].bitmap
    @descriptionSprite["desc_text"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    drawTextEx(@descriptionSprite["desc_text"].bitmap,
         180*@resizeX,380*@resizeY,Graphics.width-180*@resizeX,3,@page2Clauses[@mainSelectY][1][@page2SelectY][1],textColor,outlineColor)
  end
  
  def pbUpdateModes2
    case @page2Clauses[@mainSelectY][0]
    when _INTL("Nuzlocke Clauses")
      if @nuzlockeSelected.include?(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
        @nuzlockeSelected.delete(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
      else
        @nuzlockeSelected.push(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
      end
    when _INTL("Randomizer Choices")
      if @randomizedSelected.include?(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
        @randomizedSelected.delete(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
      else
        @randomizedSelected.push(@page2Clauses[@mainSelectY][1][@page2SelectY][0])
      end
    #when other clauses
    else
    end
  end
  
  def pbTransition2
    #Move buttons to the right
    for i in 1..33
      @buttonSprites2.each do |key, value|
        @buttonSprites2[key].x+=i*@resizeX
      end
      @buttonSprites1.each do |key, value|
        @buttonSprites1[key].x+=i*@resizeX
      end
      Graphics.update
    end
  end
  
  def pbTransition3
    #Move buttons to the left
    for i in 1..33
      @buttonSprites2.each do |key, value|
        @buttonSprites2[key].x-=i*@resizeX
      end
      @buttonSprites3.each do |key, value|
        @buttonSprites3[key].x-=i*@resizeX
      end
      Graphics.update
    end
  end
################################################################################
#                              Third Page
################################################################################
  def pbSetUpButtons3
    pbDisposeSpriteHash(@buttonSpritesMain)
    pbDisposeSpriteHash(@buttonSprites3)
    pageTitle = @page3Clauses[@mainSelectY][@page2SelectY][0]
    pageSubTitle = @page3Clauses[@mainSelectY][@page2SelectY][2]
    for i in 0...@page3Clauses[@mainSelectY][@page2SelectY][1].length
      @buttonSprites3["clause_#{i}"]=Sprite.new(@viewport2)
      @buttonSprites3["clause_#{i}"].bitmap=Bitmap.new(@path+"button_op")
      @buttonSprites3["clause_#{i}"].src_rect=Rect.new(0,0,257,87)
      @buttonSprites3["clause_#{i}"].x=180*@resizeX
      @buttonSprites3["clause_#{i}"].y=125*@resizeY+110*i*@resizeY
      @buttonSprites3["clause_#{i}"].zoom_x=@resizeX
      @buttonSprites3["clause_#{i}"].zoom_y=@resizeY
    end
    #Button text
    @buttonSprites3["button_text"]=Sprite.new(@viewport2)
    @buttonSprites3["button_text"].bitmap.clear if @buttonSprites3["button_text"].bitmap
    @buttonSprites3["button_text"].bitmap=Bitmap.new(Graphics.width,Graphics.height*10)
    textpos=[]
    pbSetDSIFont(@buttonSprites3["button_text"].bitmap)
    @buttonSprites3["button_text"].bitmap.font.size=(42*@resizeY).floor
    textColor=Color.new(255,255,255)
    outlineColor=Color.new(0,0,0)
    for i in 0...@page3Clauses[@mainSelectY][@page2SelectY][1].length
      textpos.push([@page3Clauses[@mainSelectY][@page2SelectY][1][i][0],312*@resizeX,145*@resizeY+110*i*@resizeY,2,textColor,outlineColor])
    end
    pbDrawTextPositions(@buttonSprites3["button_text"].bitmap,textpos)
    
    #Main text
    @buttonSpritesMain["main_text"]=Sprite.new(@viewport3)
    @buttonSpritesMain["main_text"].bitmap.clear if @buttonSpritesMain["main_text"].bitmap
    @buttonSpritesMain["main_text"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    pbSetDSIFont(@buttonSpritesMain["main_text"].bitmap)
    textpos=[]
    textColor=Color.new(0,0,0)
    outlineColor=Color.new(55,55,55)
    @buttonSpritesMain["main_text"].bitmap.font.size=(50*@resizeY).floor
    textpos.push([_INTL("#{pageTitle}"),Graphics.width/2,0*@resizeY,2,textColor,outlineColor])
    textpos.push([_INTL("#{pageSubTitle}"),Graphics.width/2,35*@resizeY,2,textColor,outlineColor])
    pbDrawTextPositions(@buttonSpritesMain["main_text"].bitmap,textpos)
    textpos=[]
    @buttonSpritesMain["main_text"].bitmap.font.size=(42*@resizeY).floor
    textpos.push([_INTL("Selected"),80*@resizeX,95*@resizeY-(10/@resizeY),2,textColor,outlineColor])
    pbDrawTextPositions(@buttonSpritesMain["main_text"].bitmap,textpos)
    textpos=[]
    @buttonSpritesMain["main_text"].bitmap.font.size=32
    case @page3Clauses[@mainSelectY][@page2SelectY][0]
    when _INTL("PP SubClauses")
      if @PPClausesSelected.length>0
        for i in 0...@PPClausesSelected.length
          textpos.push([_INTL(@PPClausesSelected[i]),80*@resizeX,150*@resizeY+40*i*@resizeY,2,textColor,outlineColor])
        end
      end
    when _INTL("Catch Tokens")
      if @catchTokensSelected.length>0
        for i in 0...@catchTokensSelected.length
          textpos.push([_INTL(@catchTokensSelected[i]),80*@resizeX,150*@resizeY+40*i*@resizeY,2,textColor,outlineColor])
        end
      end
    when _INTL("Encounter Tokens")
      if @encounterTokensSelected.length>0
        for i in 0...@encounterTokensSelected.length
          textpos.push([_INTL(@encounterTokensSelected[i]),80*@resizeX,150*@resizeY+40*i*@resizeY,2,textColor,outlineColor])
        end
      end
    when _INTL("Revive Tokens")
      if @reviveTokensSelected.length>0
        for i in 0...@reviveTokensSelected.length
          textpos.push([_INTL(@reviveTokensSelected[i]),80*@resizeX,150*@resizeY+40*i*@resizeY,2,textColor,outlineColor])
        end
      end
    when _INTL("Randomized Battle Options")
      if @randomPokemonSubClausesSelected.length>0
        for i in 0...@randomPokemonSubClausesSelected.length
          textpos.push([_INTL(@randomPokemonSubClausesSelected[i]),80*@resizeX,150*@resizeY+40*i*@resizeY,2,textColor,outlineColor])
        end
      end
    when _INTL("Randomized Gift Pokemon Options")
      if @randomPokemonGiftSelected.length>0
        for i in 0...@randomPokemonGiftSelected.length
          textpos.push([_INTL(@randomPokemonGiftSelected[i]),80*@resizeX,150*@resizeY+40*i*@resizeY,2,textColor,outlineColor])
        end
      end
    when _INTL("Randomized Event Pokemon Options")
      if @randomEventPokemonSelected.length>0
        for i in 0...@randomEventPokemonSelected.length
          textpos.push([_INTL(@randomEventPokemonSelected[i]),80*@resizeX,150*@resizeY+40*i*@resizeY,2,textColor,outlineColor])
        end
      end
    end
    pbDrawTextPositions(@buttonSpritesMain["main_text"].bitmap,textpos)
  end
  
  def pbRun3
    pbUpdateButtons3
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::C)
        pbUpdateModes3
        pbSetUpButtons3
        @page3SelectY.times do
          @buttonSprites3.each do |key, value|
            @buttonSprites3[key].y-=87*@resizeY
          end
        end
        pbUpdateButtons3
        Graphics.update
      end
      break if Input.trigger?(Input::B)
      if Input.trigger?(Input::DOWN) && @page3SelectY<(@page3Clauses[@mainSelectY][@page2SelectY][1].length-1)
        @buttonSprites3.each do |key, value|
          @buttonSprites3[key].y-=87*@resizeY
        end
        @page3SelectY+=1
        pbUpdateButtons3
        Graphics.update
      end
      if Input.trigger?(Input::UP) && @page3SelectY>0
        @buttonSprites3.each do |key, value|
          @buttonSprites3[key].y+=87*@resizeY
        end
        @page3SelectY-=1
        pbUpdateButtons3
        Graphics.update
      end
    end
  end
  
  def pbUpdateButtons3
     for i in 0...@page3Clauses[@mainSelectY][@page2SelectY][1].length
      if i==@page3SelectY
        @buttonSprites3["clause_#{i}"].src_rect=Rect.new(257,0,257,87)
      else
       @buttonSprites3["clause_#{i}"].src_rect=Rect.new(0,0,257,87)
      end
    end
    pbDisposeSpriteHash(@descriptionSprite)
    @descriptionSprite={}
    textpos=[]
    textColor=Color.new(255,255,255)
    outlineColor=Color.new(0,0,0)
    @descriptionSprite["desc_text"]=Sprite.new(@viewport3)
    @descriptionSprite["desc_text"].bitmap.clear if @descriptionSprite["desc_text"].bitmap
    @descriptionSprite["desc_text"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    drawTextEx(@descriptionSprite["desc_text"].bitmap,
         180*@resizeX,380*@resizeY,Graphics.width-180*@resizeX,3,@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][1],textColor,outlineColor)
  end
  
  def pbUpdateModes3
    case @page3Clauses[@mainSelectY][@page2SelectY][0]
    when _INTL("PP SubClauses")
      if @page3Clauses[@mainSelectY][@page2SelectY][3]
        if @PPClausesSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @PPClausesSelected.delete(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        else
          @PPClausesSelected.push(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        end
      else
        if @PPClausesSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @PPClausesSelected=[]
        else
          @PPClausesSelected=[@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0]]
        end
      end
    when _INTL("Catch Tokens")
      if @page3Clauses[@mainSelectY][@page2SelectY][3]
        if @catchTokensSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @catchTokensSelected.delete(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        else
          @catchTokensSelected.push(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        end
      else
        if @catchTokensSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @catchTokensSelected=[]
        else
          @catchTokensSelected=[@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0]]
        end
      end
    when _INTL("Encounter Tokens")
      if @page3Clauses[@mainSelectY][@page2SelectY][3]
        if @encounterTokensSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @encounterTokensSelected.delete(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        else
          @encounterTokensSelected.push(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        end
      else
        if @encounterTokensSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @encounterTokensSelected=[]
        else
          @encounterTokensSelected=[@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0]]
        end
      end
    when _INTL("Revive Tokens")
      if @page3Clauses[@mainSelectY][@page2SelectY][3]
        if @reviveTokensSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @reviveTokensSelected.delete(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        else
          @reviveTokensSelected.push(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        end
      else
        if @reviveTokensSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @reviveTokensSelected=[]
        else
          @reviveTokensSelected=[@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0]]
        end
      end
    when _INTL("Randomized Battle Options")
      if @page3Clauses[@mainSelectY][@page2SelectY][3]
        if @randomPokemonSubClausesSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @randomPokemonSubClausesSelected.delete(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        else
          @randomPokemonSubClausesSelected.push(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        end
      else
        if @randomPokemonSubClausesSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @randomPokemonSubClausesSelected=[]
        else
          @randomPokemonSubClausesSelected=[@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0]]
        end
      end
    when _INTL("Randomized Gift Pokemon Options")
      if @page3Clauses[@mainSelectY][@page2SelectY][3]
        if @randomPokemonGiftSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @randomPokemonGiftSelected.delete(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        else
          @randomPokemonGiftSelected.push(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        end
      else
        if @randomPokemonGiftSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @randomPokemonGiftSelected=[]
        else
          @randomPokemonGiftSelected=[@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0]]
        end
      end
    when _INTL("Randomized Event Pokemon Options")
      if @page3Clauses[@mainSelectY][@page2SelectY][3]
        if @randomEventPokemonSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @randomEventPokemonSelected.delete(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        else
          @randomEventPokemonSelected.push(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
        end
      else
        if @randomEventPokemonSelected.include?(@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0])
          @randomEventPokemonSelected=[]
        else
          @randomEventPokemonSelected=[@page3Clauses[@mainSelectY][@page2SelectY][1][@page3SelectY][0]]
        end
      end
    end
  end
  
  def pbTransition4
    #Move buttons to the right
    for i in 1..33
      @buttonSprites2.each do |key, value|
        @buttonSprites2[key].x+=i*@resizeX
      end
      @buttonSprites3.each do |key, value|
        @buttonSprites3[key].x+=i*@resizeX
      end
      Graphics.update
    end
  end
################################################################################
#                              Exit
################################################################################  
  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@buttonSpritesMain)
    pbDisposeSpriteHash(@buttonSprites1)
    pbDisposeSpriteHash(@buttonSprites2)
    pbDisposeSpriteHash(@buttonSprites3)
    pbDisposeSpriteHash(@descriptionSprite)
    count=0
    #Activate appropriate switches
    if @curSelected.length>0
      for i in 0...@curSelected.length
        case @curSelected[i]
        when _INTL("Nuzlocke")
          $PokemonGlobal.nuzlocke=true
          if @nuzlockeSelected.length>0
            for i in 0...@nuzlockeSelected.length
              case @nuzlockeSelected[i]
              when _INTL("Dubious Clause")
                $PokemonGlobal.dubiousClause=true
              when _INTL("PP Clause")
                $PokemonGlobal.ppClause=true
                if @PPClausesSelected.length>0
                  for i in 0...@PPClausesSelected.length
                    case @PPClausesSelected[i]
                    when _INTL("No PP Items")
                      $PokemonGlobal.allowPPItems=false
                    when _INTL("PP Token")
                      $PokemonGlobal.ppTokens=0
                    end
                  end
                end
              when _INTL("Catch Tokens")
                $PokemonGlobal.catchTokens=0
                if @catchTokensSelected.length>0
                  for i in 0...@catchTokensSelected.length
                    case @catchTokensSelected[i]
                    when _INTL("After Gift")
                      $PokemonGlobal.catchTokenAfterGiftPokemon=true
                    when _INTL("After Gym")
                      $PokemonGlobal.catchTokenAfterGymLeader=true
                    end
                  end
                else
                  $PokemonGlobal.catchTokenAfterGymLeader=true
                end
              when _INTL("Encounter Tokens")
                $PokemonGlobal.encounterTokens=0
                if @encounterTokensSelected.length>0
                  for i in 0...@encounterTokensSelected.length
                    case @encounterTokensSelected[i]
                    when _INTL("After Gift")
                      $PokemonGlobal.encounterTokenAfterGiftPokemon=true
                    when _INTL("After Gym")
                      $PokemonGlobal.encounterTokenAfterGymLeader=true
                    end
                  end
                else
                  $PokemonGlobal.encounterTokenAfterGymLeader=true
                end
              when _INTL("Revive Tokens")
                $PokemonGlobal.reviveTokens=0
                if @reviveTokensSelected.length>0
                  for i in 0...@reviveTokensSelected.length
                    case @reviveTokensSelected[i]
                    when _INTL("After Gift")
                      $PokemonGlobal.reviveTokenAfterGiftPokemon=true
                    when _INTL("After Gym")
                      $PokemonGlobal.reviveTokenAfterGymLeader=true
                    end
                  end
                else
                  $PokemonGlobal.reviveTokenAfterGymLeader=true
                end
              when _INTL("Shiny Clause")
                $PokemonGlobal.shinyClause=true
              end
            end
          end
        when _INTL("No Running")
          $PokemonGlobal.noRunningLocke=true
        when _INTL("Randomize")
          if @randomizedSelected.length>0
            for i in 0...@randomizedSelected.length
              case @randomizedSelected[i]
              when _INTL("Randomized Battles")
                if @randomPokemonSubClausesSelected.length>0
                  for i in 0...@randomPokemonSubClausesSelected.length
                    case @randomPokemonSubClausesSelected[i]
                    when _INTL("Pure Random")
                      $PokemonGlobal.encounterPureRandom=true
                    when _INTL("Set Random")
                      $PokemonGlobal.encounterSetRandom=true
                    when _INTL("Set Psuedo-Random")
                      $PokemonGlobal.encounterPsuedoRandom=true
                    end
                  end
                else
                  $PokemonGlobal.encounterPureRandom=true
                end
              when _INTL("Randomized Gifts")
                if @randomPokemonGiftSelected.length>0
                  for i in 0...@randomPokemonGiftSelected.length
                    case @randomPokemonGiftSelected[i]
                    when _INTL("Pure Random")
                      $PokemonGlobal.giftPureRandom=true
                    when _INTL("Set Random")
                      $PokemonGlobal.giftSetRandom=true
                    when _INTL("Set Psuedo-Random")
                      $PokemonGlobal.giftPsuedoRandom=true
                    end
                  end
                else
                  $PokemonGlobal.giftPureRandom=true
                end
              when _INTL("Randomized Events")
                if @randomEventPokemonSelected.length>0
                  for i in 0...@randomEventPokemonSelected.length
                    case @randomEventPokemonSelected[i]
                    when _INTL("Pure Random")
                      $PokemonGlobal.eventPureRandom=true
                    when _INTL("Set Random")
                      $PokemonGlobal.eventSetRandom=true
                    when _INTL("Set Psuedo-Random")
                      $PokemonGlobal.eventPsuedoRandom=true
                    end
                  end
                else
                  $PokemonGlobal.eventPureRandom=true
                end
              when _INTL("Randomized Items")
                $PokemonGlobal.randomItems=true
              when _INTL("Randomized Moves")
                $PokemonGlobal.randomMoves=true
              when _INTL("Randomized Abilities")
                $PokemonGlobal.randomAbilities=true
              end
            end
          else #If no clauses were selected, default to pure random
            $PokemonGlobal.encounterPureRandom=true
            $PokemonGlobal.giftPureRandom=true
            $PokemonGlobal.eventPureRandom=true
          end
        when _INTL("No Evolutions")
          $PokemonGlobal.noEvoLocke=true
        when _INTL("Solo Run")
          $PokemonGlobal.soloLocke=true
        when _INTL("Inverse Locke")
          $PokemonGlobal.inverseLocke=true
        when _INTL("No Items")
          $PokemonGlobal.noItemsLocke=true
        when _INTL("No TMs")
          $PokemonGlobal.noTMLocke=true
        end
      end
    end
  end
end