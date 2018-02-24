def pbItemIconFile(item)
  return nil if !item
  bitmapFileName=nil
  if item==0
    bitmapFileName=sprintf("Graphics/Icons/itemBack")
  else
    bitmapFileName=sprintf("Graphics/Icons/item%s",getConstantName(PBItems,item)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=sprintf("Graphics/Icons/item%03d",item)
    end
  end
  if pbIsMachine?(item) && !pbResolveBitmap(bitmapFileName)
    movedata=pbRgssOpen("Data/moves.dat")
    movedata.pos=$ItemData[item][ITEMMACHINE]*14+3
    typeid=movedata.fgetb
    movedata.close
    type=getConstantName(PBTypes,typeid)
    bitmapFileName=sprintf("Graphics/Icons/TM_%s",type)
  end
  return bitmapFileName
end