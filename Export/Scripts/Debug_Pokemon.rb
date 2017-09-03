module PokemonDebugMixin
  def pbPokemonDebugCommands
    commands = CommandMenuList.new
    commands.add("main","hpstatusmenu",_INTL("HP/Status..."))
      commands.add("hpstatusmenu","sethp",_INTL("Set HP"))
      commands.add("hpstatusmenu","setstatus",_INTL("Set status"))
      commands.add("hpstatusmenu","fullheal",_INTL("Fully heal"))
      commands.add("hpstatusmenu","makefainted",_INTL("Make fainted"))
      commands.add("hpstatusmenu","setpokerus",_INTL("Set Pokérus"))
    
    commands.add("main","levelstats",_INTL("Level/stats..."))
      commands.add("levelstats","setlevel",_INTL("Set level"))
      commands.add("levelstats","setexp",_INTL("Set Exp"))
      commands.add("levelstats","hiddenvalues",_INTL("EV/IV/pID..."))
      commands.add("levelstats","sethappiness",_INTL("Set happiness"))
      commands.add("levelstats","conteststats",_INTL("Contest stats..."))
        commands.add("conteststats","setbeauty",_INTL("Set Beauty"))
        commands.add("conteststats","setcool",_INTL("Set Cool"))
        commands.add("conteststats","setcute",_INTL("Set Cute"))
        commands.add("conteststats","setsmart",_INTL("Set Smart"))
        commands.add("conteststats","settough",_INTL("Set Tough"))
        commands.add("conteststats","setsheen",_INTL("Set Sheen"))
    
    commands.add("main","moves",_INTL("Moves..."))
      commands.add("moves","teachmove",_INTL("Teach move"))
      commands.add("moves","forgetmove",_INTL("Forget move"))
      commands.add("moves","resetmoves",_INTL("Reset moves"))
      commands.add("moves","setmovepp",_INTL("Set move PP"))
      commands.add("moves","setinitialmoves",_INTL("Reset initial moves"))
    
    commands.add("main","setability",_INTL("Set ability"))
    commands.add("main","setnature",_INTL("Set nature"))
    commands.add("main","setgender",_INTL("Set gender"))
    commands.add("main","speciesform",_INTL("Species/form..."))
    
    commands.add("main","cosmetic",_INTL("Cosmetic info..."))
      commands.add("cosmetic","setshininess",_INTL("Set shininess"))
      commands.add("cosmetic","setpokeball",_INTL("Set Poké Ball"))
      commands.add("cosmetic","setribbons",_INTL("Set ribbons"))
      commands.add("cosmetic","setnickname",_INTL("Set nickname"))
      commands.add("cosmetic","ownership",_INTL("Ownership..."))
    
    commands.add("main","setegg",_INTL("Set egg"))
    commands.add("main","shadowpkmn",_INTL("Shadow Pkmn..."))
    commands.add("main","mysterygift",_INTL("Mystery Gift"))
    commands.add("main","duplicate",_INTL("Duplicate"))
    commands.add("main","delete",_INTL("Delete"))
    return commands
  end

  def pbPokemonDebugActions(command,pkmn,pkmnid,heldpoke=nil)
    case command
    #===========================================================================
    when "sethp"
      if pkmn.isEgg?
        pbDisplay(_INTL("{1} is an egg.",pkmn.name))
      else
        params = ChooseNumberParams.new
        params.setRange(0,pkmn.totalhp)
        params.setDefaultValue(pkmn.hp)
        newhp = Kernel.pbMessageChooseNumber(
           _INTL("Set {1}'s HP (max. {2}).",pkmn.name,pkmn.totalhp),params) { @scene.update }
        if newhp!=pkmn.hp
          pkmn.hp = newhp
          pbRefreshSingle(pkmnid)
        end
      end
    #===========================================================================
    when "setstatus"
      if pkmn.isEgg?
        pbDisplay(_INTL("{1} is an egg.",pkmn.name))
      elsif pkmn.hp<=0
        pbDisplay(_INTL("{1} is fainted, can't change status.",pkmn.name))
      else
        cmd = 0
        loop do
          cmd = @scene.pbShowCommands(_INTL("Set {1}'s status.",pkmn.name),[
             _INTL("[Cure]"),
             _INTL("Sleep"),
             _INTL("Poison"),
             _INTL("Burn"),
             _INTL("Paralysis"),
             _INTL("Frozen")
          ],cmd)
          break if cmd<0
          case cmd
          when 0   # Cure
            pkmn.healStatus
            pbDisplay(_INTL("{1}'s status was cured.",pkmn.name))
            pbRefreshSingle(pkmnid)
          else   # Give status problem
            count = 0
            cancel = false
            if cmd==PBStatuses::SLEEP
              params = ChooseNumberParams.new
              params.setRange(0,9)
              params.setDefaultValue(3)
              count = Kernel.pbMessageChooseNumber(
                 _INTL("Set the Pokémon's sleep count."),params) { @scene.update }
              cancel = true if count<=0
            end
            if !cancel
              pkmn.status      = cmd
              pkmn.statusCount = count
              pbRefreshSingle(pkmnid)
            end
          end
        end
      end
    #===========================================================================
    when "fullheal"
      if pkmn.isEgg?
        pbDisplay(_INTL("{1} is an egg.",pkmn.name))
      else
        pkmn.heal
        pbDisplay(_INTL("{1} was fully healed.",pkmn.name))
        pbRefreshSingle(pkmnid)
      end
    #===========================================================================
    when "makefainted"
      if pkmn.isEgg?
        pbDisplay(_INTL("{1} is an egg.",pkmn.name))
      else
        pkmn.hp = 0
        pbRefreshSingle(pkmnid)
      end
    #===========================================================================
    when "setpokerus"
      cmd = 0
      loop do
        pokerus = (pkmn.pokerus) ? pkmn.pokerus : 0
        msg = [_INTL("{1} doesn't have Pokérus.",pkmn.name),
               _INTL("Has strain {1}, infectious for {2} more days.",pokerus/16,pokerus%16),
               _INTL("Has strain {1}, not infectious.",pokerus/16)][pkmn.pokerusStage]
        cmd = @scene.pbShowCommands(msg,[
           _INTL("Give random strain"),
           _INTL("Make not infectious"),
           _INTL("Clear Pokérus")],cmd)
        break if cmd<0
        case cmd
        when 0   # Give random strain
          pkmn.givePokerus
          pbRefreshSingle(pkmnid)
        when 1   # Make not infectious
          if pokerus>0
            strain = pokerus/16
            p = strain<<4
            pkmn.pokerus = p
            pbRefreshSingle(pkmnid)
          end
        when 2   # Clear Pokérus
          pkmn.pokerus = 0
          pbRefreshSingle(pkmnid)
        end
      end
    #===========================================================================
    when "setlevel"
      if pkmn.isEgg?
        pbDisplay(_INTL("{1} is an egg.",pkmn.name))
      else
        params = ChooseNumberParams.new
        params.setRange(1,PBExperience::MAXLEVEL)
        params.setDefaultValue(pkmn.level)
        level = Kernel.pbMessageChooseNumber(
           _INTL("Set the Pokémon's level (max. {1}).",PBExperience::MAXLEVEL),params) { @scene.update }
        if level!=pkmn.level
          pkmn.level = level
          pkmn.calcStats
          pbRefreshSingle(pkmnid)
        end
      end
    #===========================================================================
    when "setexp"
      if pkmn.isEgg?
        pbDisplay(_INTL("{1} is an egg.",pkmn.name))
      else
        minxp = PBExperience.pbGetStartExperience(pkmn.level,pkmn.growthrate)
        maxxp = PBExperience.pbGetStartExperience(pkmn.level+1,pkmn.growthrate)
        if minxp==maxxp
          pbDisplay(_INTL("{1} is at the maximum level.",pkmn.name))
        else
          params = ChooseNumberParams.new
          params.setRange(minxp,maxxp-1)
          params.setDefaultValue(pkmn.exp)
          newexp = Kernel.pbMessageChooseNumber(
             _INTL("Set the Pokémon's Exp (range {1}-{2}).",minxp,maxxp-1),params) { @scene.update }
          if newexp!=pkmn.exp
            pkmn.exp = newexp
            pkmn.calcStats
            pbRefreshSingle(pkmnid)
          end
        end
      end
    #===========================================================================
    when "hiddenvalues"
      numstats = 6
      cmd = 0
      loop do
        persid = sprintf("0x%08X",pkmn.personalID)
        cmd = @scene.pbShowCommands(_INTL("Personal ID is {1}.",persid),[
             _INTL("Set EVs"),
             _INTL("Set IVs"),
             _INTL("Randomise pID")],cmd)
        break if cmd<0
        case cmd
        when 0   # Set EVs
          cmd2 = 0
          loop do
            evcommands = []
            for i in 0...numstats
              evcommands.push(PBStats.getName(i)+" (#{pkmn.ev[i]})")
            end
            cmd2 = @scene.pbShowCommands(_INTL("Change which EV?"),evcommands,cmd2)
            break if cmd2<0
            if cmd2<numstats
              params = ChooseNumberParams.new
              params.setRange(0,PokeBattle_Pokemon::EVSTATLIMIT)
              params.setDefaultValue(pkmn.ev[cmd2])
              params.setCancelValue(pkmn.ev[cmd2])
              f = Kernel.pbMessageChooseNumber(_INTL("Set the EV for {1} (max. {2}).",
                 PBStats.getName(cmd2),PokeBattle_Pokemon::EVSTATLIMIT),params) { @scene.update }
              if f!=pkmn.ev[cmd2]
                pkmn.ev[cmd2] = f
                pkmn.calcStats
                pbRefreshSingle(pkmnid)
              end
            end
          end
        when 1   # Set IVs
          cmd2 = 0
          loop do
            hiddenpower = pbHiddenPower(pkmn.iv)
            msg = _INTL("Hidden Power:\n{1}, power {2}.",PBTypes.getName(hiddenpower[0]),hiddenpower[1])
            ivcommands = []
            for i in 0...numstats
              ivcommands.push(PBStats.getName(i)+" (#{pkmn.iv[i]})")
            end
            ivcommands.push(_INTL("Randomise all"))
            cmd2 = @scene.pbShowCommands(msg,ivcommands,cmd2)
            break if cmd2<0
            if cmd2<numstats
              params = ChooseNumberParams.new
              params.setRange(0,31)
              params.setDefaultValue(pkmn.iv[cmd2])
              params.setCancelValue(pkmn.iv[cmd2])
              f = Kernel.pbMessageChooseNumber(_INTL("Set the IV for {1} (max. 31).",
                 PBStats.getName(cmd2)),params) { @scene.update }
              if f!=pkmn.iv[cmd2]
                pkmn.iv[cmd2] = f
                pkmn.calcStats
                pbRefreshSingle(pkmnid)
              end
            elsif cmd2==ivcommands.length-1
              for i in 0...numstats
                pkmn.iv[i] = rand(32)
              end
              pkmn.calcStats
              pbRefreshSingle(pkmnid)
            end
          end
        when 2   # Randomise pID
          pkmn.personalID = rand(256)
          pkmn.personalID |= rand(256)<<8
          pkmn.personalID |= rand(256)<<16
          pkmn.personalID |= rand(256)<<24
          pkmn.calcStats
          pbRefreshSingle(pkmnid)
        end
      end
    #===========================================================================
    when "sethappiness"
      params = ChooseNumberParams.new
      params.setRange(0,255)
      params.setDefaultValue(pkmn.happiness)
      h = Kernel.pbMessageChooseNumber(
         _INTL("Set the Pokémon's happiness (max. 255)."),params) { @scene.update }
      if h!=pkmn.happiness
        pkmn.happiness = h
        pbRefreshSingle(pkmnid)
      end
    #===========================================================================
    when "setbeauty", "setcool", "setcute", "setsmart", "settough", "setsheen"
      case command
      when "setbeauty"; statname = _INTL("Beauty"); defval = pkmn.beauty
      when "setcool";   statname = _INTL("Cool");   defval = pkmn.cool
      when "setcute";   statname = _INTL("Cute");   defval = pkmn.cute
      when "setsmart";  statname = _INTL("Smart");  defval = pkmn.smart
      when "settough";  statname = _INTL("Tough");  defval = pkmn.tough
      when "setsheen";  statname = _INTL("Sheen");  defval = pkmn.sheen
      end
      params = ChooseNumberParams.new
      params.setRange(0,255)
      params.setDefaultValue(defval)
      newval = Kernel.pbMessageChooseNumber(
         _INTL("Set the Pokémon's {1} (max. 255).",statname),params) { @scene.update }
      if newval!=defval
        case command
        when "setbeauty"; pkmn.beauty = newval
        when "setcool";   pkmn.cool = newval
        when "setcute";   pkmn.cute = newval
        when "setsmart";  pkmn.smart = newval
        when "settough";  pkmn.tough = newval
        when "setsheen";  pkmn.sheen = newval
        end
        pbRefreshSingle(pkmnid)
      end
    #===========================================================================
    when "teachmove"
      move = pbChooseMoveList
      if move!=0
        pbLearnMove(pkmn,move)
        pbRefreshSingle(pkmnid)
      end
    #===========================================================================
    when "forgetmove"
      moveindex = pbChooseMove(pkmn,_INTL("Choose move to forget."))
      if moveindex>=0
        movename = PBMoves.getName(pkmn.moves[moveindex].id)
        pkmn.pbDeleteMoveAtIndex(moveindex)
        pbDisplay(_INTL("{1} forgot {2}.",pkmn.name,movename))
        pbRefreshSingle(pkmnid)
      end
    #===========================================================================
    when "resetmoves"
      pkmn.resetMoves
      pbDisplay(_INTL("{1}'s moves were reset.",pkmn.name))
      pbRefreshSingle(pkmnid)
    #===========================================================================
    when "setmovepp"
      cmd = 0
      loop do
        commands = []
        for i in pkmn.moves
          break if i.id==0
          if i.totalpp==0
            commands.push(_INTL("{1} (PP: ---)",PBMoves.getName(i.id),i.pp,i.totalpp))
          else
            commands.push(_INTL("{1} (PP: {2}/{3})",PBMoves.getName(i.id),i.pp,i.totalpp))
          end
        end
        commands.push(_INTL("Restore all PP"))
        cmd = @scene.pbShowCommands(_INTL("Alter PP of which move?"),commands,cmd)
        break if cmd<0
        if cmd>=0 && cmd<commands.length-1   # Move
          move = pkmn.moves[cmd]
          movename = PBMoves.getName(move.id)
          if move.totalpp==0
            pbDisplay(_INTL("{1} has infinite PP.",movename))
          else
            cmd2 = 0
            loop do
              msg = _INTL("{1}: PP {2}/{3} (PP Up {4}/3)",movename,move.pp,move.totalpp,move.ppup)
              cmd2 = @scene.pbShowCommands(msg,[
                 _INTL("Set PP"),
                 _INTL("Full PP"),
                 _INTL("Set PP Up")],cmd2)
              break if cmd2<0
              case cmd2
              when 0   # Change PP
                params = ChooseNumberParams.new
                params.setRange(0,move.totalpp)
                params.setDefaultValue(move.pp)
                h = Kernel.pbMessageChooseNumber(
                   _INTL("Set PP of {1} (max. {2}).",movename,move.totalpp),params) { @scene.update }
                move.pp = h
              when 1   # Full PP
                move.pp = move.totalpp
              when 2   # Change PP Up
                params = ChooseNumberParams.new
                params.setRange(0,3)
                params.setDefaultValue(move.ppup)
                h = Kernel.pbMessageChooseNumber(
                   _INTL("Set PP Up of {1} (max. 3).",movename),params) { @scene.update }
                move.ppup = h
                move.pp = move.totalpp if move.pp>move.totalpp
              end
            end
          end
        elsif cmd==commands.length-1   # Restore all PP
          pkmn.healPP
        end
      end
    #===========================================================================
    when "setinitialmoves"
      pkmn.pbRecordFirstMoves
      pbDisplay(_INTL("{1}'s moves were set as its first-known moves.",pkmn.name))
      pbRefreshSingle(pkmnid)
    #===========================================================================
    when "setability"
      cmd = 0
      loop do
        abils = pkmn.getAbilityList
        oldabil = PBAbilities.getName(pkmn.ability)
        commands = []
        for i in abils
          commands.push(((i[1]<2) ? "" : "(H) ")+PBAbilities.getName(i[0]))
        end
        commands.push(_INTL("Remove override"))
        msg = [_INTL("Ability {1} is natural.",oldabil),
               _INTL("Ability {1} is being forced.",oldabil)][pkmn.abilityflag!=nil ? 1 : 0]
        cmd = @scene.pbShowCommands(msg,commands,cmd)
        break if cmd<0
        if cmd>=0 && cmd<abils.length   # Set ability override
          pkmn.setAbility(abils[cmd][1])
        elsif cmd==abils.length   # Remove override
          pkmn.abilityflag = nil
        end
        pbRefreshSingle(pkmnid)
      end
    #===========================================================================
    when "setnature"
      commands = []
      (PBNatures.getCount).times do |i|
        nd5=(i/5).floor
        nm5=(i%5).floor
        if nd5!=nm5
          text = _INTL("{1} (+{2}, -{3})",PBNatures.getName(i),
             PBStats.getNameBrief(nd5+1),PBStats.getNameBrief(nm5+1))
        else
          text = _INTL("{1} (---)",PBNatures.getName(i))
        end
        commands.push(text)
      end
      commands.push(_INTL("[Remove override]"))
      cmd = pkmn.nature
      loop do
        oldnature = PBNatures.getName(pkmn.nature)
        msg = [_INTL("Nature {1} is natural.",oldnature),
               _INTL("Nature {1} is being forced.",oldnature)][pkmn.natureflag ? 1 : 0]
        cmd = @scene.pbShowCommands(msg,commands,cmd)
        break if cmd<0
        if cmd>=0 && cmd<PBNatures.getCount   # Set nature override
          pkmn.setNature(cmd)
          pkmn.calcStats
        elsif cmd==PBNatures.getCount   # Remove override
          pkmn.natureflag = nil
        end
        pbRefreshSingle(pkmnid)
      end
    #===========================================================================
    when "setgender"
      if pkmn.isSingleGendered?
        pbDisplay(_INTL("{1} is single-gendered or genderless.",pkmn.speciesName))
      else
        cmd = 0
        loop do
          oldgender = (pkmn.isMale?) ? _INTL("male") : _INTL("female")
          msg = [_INTL("Gender {1} is natural.",oldgender),
               _INTL("Gender {1} is being forced.",oldgender)][pkmn.genderflag ? 1 : 0]
          cmd = @scene.pbShowCommands(msg,[
             _INTL("Make male"),
             _INTL("Make female"),
             _INTL("Remove override")],cmd)
          break if cmd<0
          case cmd
          when 0   # Make male
            pkmn.makeMale
            if !pkmn.isMale?
              pbDisplay(_INTL("{1}'s gender couldn't be changed.",pkmn.name))
            end
          when 1   # Make female
            pkmn.makeFemale
            if !pkmn.isFemale?
              pbDisplay(_INTL("{1}'s gender couldn't be changed.",pkmn.name))
            end
          when 2   # Remove override
            pkmn.genderflag = nil
          end
          pbSeenForm(pkmn)
          pbRefreshSingle(pkmnid)
        end
      end
    #===========================================================================
    when "speciesform"
      cmd = 0
      loop do
        msg = [_INTL("Species {1}, form {2}.",pkmn.speciesName,pkmn.form),
               _INTL("Species {1}, form {2} (forced).",pkmn.speciesName,pkmn.form)][(pkmn.forcedForm!=nil) ? 1 : 0]
        cmd = @scene.pbShowCommands(msg,[
           _INTL("Set species"),
           _INTL("Set form"),
           _INTL("Remove override")],cmd)
        break if cmd<0
        case cmd
        when 0   # Set species
          species = pbChooseSpeciesList(pkmn.species)
          if species!=0 && species!=pkmn.species
            oldspeciesname = PBSpecies.getName(pkmn.species)
            pkmn.species = species
            pkmn.forcedForm = nil
            pkmn.form = 0
            pkmn.name = PBSpecies.getName(pkmn.species) if pkmn.name==oldspeciesname
            pbSeenForm(pkmn)
            pbRefreshSingle(pkmnid)
          end
        when 1   # Set form
          cmd2 = 0
          formcmds = [[],[]]
          formdata = pbLoadFormsData
          formdata[pkmn.species] = [pkmn.species] if !formdata[pkmn.species]
          if formdata[pkmn.species]
            for form in 0...formdata[pkmn.species].length
              fSpecies = pbGetFSpeciesFromForm(pkmn.species,form)
              formname = pbGetMessage(MessageTypes::FormNames,fSpecies)
              formname = _INTL("Unnamed form") if !formname || formname==""
              formname = _INTL("{1}: {2}",form,formname)
              formcmds[0].push(form); formcmds[1].push(formname)
              cmd2 = form if pkmn.form==form
            end
          end
          if formcmds[0].length<=1
            pbDisplay(_INTL("Species {1} only has one form.",pkmn.speciesName))
          else
            cmd2 = @scene.pbShowCommands(_INTL("Set the Pokémon's form."),formcmds[1],cmd2)
            next if cmd2<0
            f = formcmds[0][cmd2]
            if f!=pkmn.form
              if MultipleForms.hasFunction?(pkmn,"getForm")
                next if !pbConfirm(_INTL("This species decides its own form. Override?"))
                pkmn.forcedForm = f
              end
              pkmn.form = f
              pbSeenForm(pkmn)
              pbRefreshSingle(pkmnid)
            end
          end
        when 2   # Remove override
          pkmn.forcedForm = nil
          pbRefreshSingle(pkmnid)
        end
      end
    #===========================================================================
    when "setshininess"
      cmd = 0
      loop do
        oldshiny = (pkmn.isShiny?) ? _INTL("shiny") : _INTL("normal")
        msg = [_INTL("Shininess ({1}) is natural.",oldshiny),
               _INTL("Shininess ({1}) is being forced.",oldshiny)][pkmn.shinyflag!=nil ? 1 : 0]
        cmd = @scene.pbShowCommands(msg,[
             _INTL("Make shiny"),
             _INTL("Make normal"),
             _INTL("Remove override")],cmd)
        break if cmd<0
        case cmd
        when 0   # Make shiny
          pkmn.makeShiny
        when 1   # Make normal
          pkmn.makeNotShiny
        when 2   # Remove override
          pkmn.shinyflag = nil
        end
        pbRefreshSingle(pkmnid)
      end
    #===========================================================================
    when "setnickname"
      cmd = 0
      loop do
        speciesname = PBSpecies.getName(pkmn.species)
        msg = [_INTL("{1} has the nickname {2}.",speciesname,pkmn.name),
               _INTL("{1} has no nickname.",speciesname)][pkmn.name==speciesname ? 1 : 0]
        cmd = @scene.pbShowCommands(msg,[
             _INTL("Rename"),
             _INTL("Erase name")],cmd)
        break if cmd<0
        case cmd
        when 0   # Rename
          oldname = (pkmn.name && pkmn.name!=speciesname) ? pkmn.name : ""
          newname = pbEnterPokemonName(_INTL("{1}'s nickname?",speciesname),
             0,PokeBattle_Pokemon::NAMELIMIT,oldname,pkmn)
          if newname && newname!=""
            pkmn.name = newname
            pbRefreshSingle(pkmnid)
          end
        when 1   # Erase name
          pkmn.name = speciesname
          pbRefreshSingle(pkmnid)
        end
      end
    #===========================================================================
    when "setpokeball"
      commands = []; balls = []
      for key in $BallTypes.keys
        item = getID(PBItems,$BallTypes[key])
        balls.push([key.to_i,PBItems.getName(item)]) if item && item>0
      end
      balls.sort! {|a,b| a[1]<=>b[1]}
      cmd = 0
      for i in 0...balls.length
        if balls[i][0]==pkmn.ballused
          cmd = i; break
        end
      end
      for i in balls
        commands.push(i[1])
      end
      loop do
        oldball = PBItems.getName(pbBallTypeToBall(pkmn.ballused))
        cmd = @scene.pbShowCommands(_INTL("{1} used.",oldball),commands,cmd)
        break if cmd<0
        pkmn.ballused = balls[cmd][0]
      end
    #===========================================================================
    when "setribbons"
      cmd = 0
      loop do
        commands = []
        for i in 1..PBRibbons.maxValue
          commands.push(_INTL("{1} {2}",
             (pkmn.hasRibbon?(i)) ? "[Y]" : "[  ]",PBRibbons.getName(i)))
        end
        commands.push(_INTL("Give all"))
        commands.push(_INTL("Clear all"))
        cmd = @scene.pbShowCommands(_INTL("{1} ribbons.",pkmn.ribbonCount),commands,cmd)
        break if cmd<0
        if cmd>=0 && cmd<PBRibbons.maxValue   # Toggle ribbon
          if pkmn.hasRibbon?(cmd+1)
            pkmn.takeRibbon(cmd+1)
          else
            pkmn.giveRibbon(cmd+1)
          end
        elsif cmd==commands.length-2   # Give all
          for i in 1..PBRibbons.maxValue
            pkmn.giveRibbon(i)
          end
        elsif cmd==commands.length-1   # Clear all
          for i in 1..PBRibbons.maxValue
            pkmn.takeRibbon(i)
          end
        end
      end
    #===========================================================================
    when "ownership"
      cmd = 0
      loop do
        gender = [_INTL("Male"),_INTL("Female"),_INTL("Unknown")][pkmn.otgender]
        msg = [_INTL("Player's Pokémon\n{1}\n{2}\n{3} ({4})",pkmn.ot,gender,pkmn.publicID,pkmn.trainerID),
               _INTL("Foreign Pokémon\n{1}\n{2}\n{3} ({4})",pkmn.ot,gender,pkmn.publicID,pkmn.trainerID)
              ][pkmn.isForeign?($Trainer) ? 1 : 0]
        cmd = @scene.pbShowCommands(msg,[
             _INTL("Make player's"),
             _INTL("Set OT's name"),
             _INTL("Set OT's gender"),
             _INTL("Random foreign ID"),
             _INTL("Set foreign ID")],cmd)
        break if cmd<0
        # Break
        case cmd
        when 0   # Make player's
          pkmn.trainerID = $Trainer.id
          pkmn.ot        = $Trainer.name
          pkmn.otgender  = $Trainer.gender
        when 1   # Set OT's name
          pkmn.ot = pbEnterPlayerName(_INTL("{1}'s OT's name?",pkmn.name),1,PLAYERNAMELIMIT)
        when 2   # Set OT's gender
          cmd2 = @scene.pbShowCommands(_INTL("Set OT's gender."),
             [_INTL("Male"),_INTL("Female"),_INTL("Unknown")],pkmn.otgender)
          pkmn.otgender = cmd2 if cmd2>=0
        when 3   # Random foreign ID
          pkmn.trainerID = $Trainer.getForeignID
        when 4   # Set foreign ID
          params = ChooseNumberParams.new
          params.setRange(0,65535)
          params.setDefaultValue(pkmn.publicID)
          val = Kernel.pbMessageChooseNumber(
             _INTL("Set the new ID (max. 65535)."),params) { @scene.update }
          pkmn.trainerID = val
          pkmn.trainerID |= val<<16
        end
      end
    #===========================================================================
    when "setegg"
      cmd = 0
      loop do
        msg = [_INTL("Not an egg"),
               _INTL("Egg with eggsteps: {1}.",pkmn.eggsteps)][pkmn.isEgg? ? 1 : 0]
        cmd = @scene.pbShowCommands(msg,[
             _INTL("Make egg"),
             _INTL("Make Pokémon"),
             _INTL("Set eggsteps to 1")],cmd)
        break if cmd<0
        case cmd
        when 0   # Make egg
          if !pkmn.isEgg? && (pbHasEgg?(pkmn.species) ||
             pbConfirm(_INTL("{1} cannot legally be an egg. Make egg anyway?",PBSpecies.getName(pkmn.species))))
            pkmn.level = EGGINITIALLEVEL
            pkmn.calcStats
            pkmn.name = _INTL("Egg")
            dexdata = pbOpenDexData
            pbDexDataOffset(dexdata,pkmn.fSpecies,21)
            pkmn.eggsteps = dexdata.fgetw
            dexdata.close
            pkmn.hatchedMap = 0
            pkmn.obtainMode = 1
            pbRefreshSingle(pkmnid)
          end
        when 1   # Make Pokémon
          if pkmn.isEgg?
            pkmn.name       = PBSpecies.getName(pkmn.species)
            pkmn.eggsteps   = 0
            pkmn.hatchedMap = 0
            pkmn.obtainMode = 0
            pbRefreshSingle(pkmnid)
          end
        when 2   # Set eggsteps to 1
          pkmn.eggsteps = 1 if pkmn.isEgg?
        end
      end
    #===========================================================================
    when "shadowpkmn"
      cmd = 0
      loop do
        msg = [_INTL("Not a Shadow Pokémon."),
               _INTL("Heart gauge is {1} (stage {2}).",pkmn.heartgauge,pkmn.heartStage)
              ][(pkmn.isShadow? rescue false) ? 1 : 0]
        cmd = @scene.pbShowCommands(msg,[
           _INTL("Make Shadow"),
           _INTL("Set heart gauge")],cmd)
        break if cmd<0
        case cmd
        when 0   # Make Shadow
          if !(pkmn.isShadow? rescue false) && pkmn.respond_to?("makeShadow")
            pkmn.makeShadow
            pbRefreshSingle(pkmnid)
          else
            pbDisplay(_INTL("{1} is already a Shadow Pokémon.",pkmn.name))
          end
        when 1   # Set heart gauge
          if (pkmn.isShadow? rescue false)
            oldheart = pkmn.heartgauge
            params = ChooseNumberParams.new
            params.setRange(0,PokeBattle_Pokemon::HEARTGAUGESIZE)
            params.setDefaultValue(pkmn.heartgauge)
            val = Kernel.pbMessageChooseNumber(
               _INTL("Set the heart gauge (max. {1}).",PokeBattle_Pokemon::HEARTGAUGESIZE),
               params) { @scene.update }
            if val!=oldheart
              pkmn.adjustHeart(oldheart-val)
              pbReadyToPurify(pkmn)
            end
          else
            pbDisplay(_INTL("{1} is not a Shadow Pokémon.",pkmn.name))
          end
        end
      end
    #===========================================================================
    when "mysterygift"
      pbCreateMysteryGift(0,pkmn)
    #===========================================================================
    when "duplicate"
      if pbConfirm(_INTL("Are you sure you want to copy this Pokémon?"))
        clonedpkmn = pkmn.clone
        clonedpkmn.iv = pkmn.iv.clone
        clonedpkmn.ev = pkmn.ev.clone
        if self.is_a?(PokemonPartyScreen)
          pbStorePokemon(clonedpkmn)
          pbHardRefresh
          pbDisplay(_INTL("The Pokémon was duplicated."))
        elsif self.is_a?(PokemonStorageScreen)
          if @storage.pbMoveCaughtToParty(clonedpkmn)
            if pkmnid[0]!=-1
              pbDisplay(_INTL("The duplicated Pokémon was moved to your party."))
            end
          else
            oldbox = @storage.currentBox
            newbox = @storage.pbStoreCaught(clonedpkmn)
            if newbox<0
              pbDisplay(_INTL("All boxes are full."))
            elsif newbox!=oldbox
              pbDisplay(_INTL("The duplicated Pokémon was moved to box \"{1}.\"",@storage[newbox].name))
              @storage.currentBox = oldbox
            end
          end
          pbHardRefresh
        end
        break
      end
    #===========================================================================
    when "delete"
      if pbConfirm(_INTL("Are you sure you want to delete this Pokémon?"))
        if self.is_a?(PokemonPartyScreen)
          @party[pkmnid] = nil
          @party.compact!
          pbHardRefresh
        elsif self.is_a?(PokemonStorageScreen)
          @scene.pbRelease(pkmnid,heldpoke)
          (heldpoke) ? @heldpkmn = nil : @storage.pbDelete(pkmnid[0],pkmnid[1])
          @scene.pbRefresh
        end
        break
      end
    end
  end

  def pbPokemonDebug(pkmn,pkmnid,heldpoke=nil)
    command = 0
    commands = pbPokemonDebugCommands
    loop do
      command = scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands.list,command)
      if command<0
        parent = commands.getParent
        if parent
          commands.currentList = parent[0]
          command = parent[1]
        else
          break
        end
      else
        cmd = commands.getCommand(command)
        if commands.hasSubMenu?(cmd)
          commands.currentList = cmd
          command = 0
        else
          pbPokemonDebugActions(cmd,pkmn,pkmnid,heldpoke)
        end
      end
    end
  end
end



class PokemonPartyScreen
  include PokemonDebugMixin
end



class PokemonStorageScreen
  include PokemonDebugMixin
end