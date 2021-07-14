function RT =  rt_merge_block(RT1,RT2)
%     v.0.0.0
%     <*LAN)<|
%
%
%
%
if iscell(RT1.rt)
l1 = size(RT1.rt);
end

if iscell(RT2.rt)
l2 = size(RT2.rt,1);
end


if iscell(RT1.rt)
RT.rt(1:l1) = RT1.rt;
RT.laten(1:l1) = RT1.laten;
        try 
            RT.misslaten(1:l1) = RT1.misslaten;
        catch
            RT.misslaten{1:l1} = [];
        end

 if iscell(RT2.rt) 
RT.rt(l1+1:l1+l2) = RT2.rt;
RT.laten(l1+1:l1+l2) = RT2.laten;
        try 
            RT.misslaten(l1+1:l1+l2) = RT2.misslaten;
        catch
            RT.misslaten{l1+1:l1+l2} = [];
        end

 else
     RT.rt{l1+1} = RT2.rt;
     RT.laten{l1+1} = RT2.laten;
     try 
         RT.misslaten{l1+1} = RT2.misslaten;
     catch
            RT.misslaten{l1+1} = [];
     end
 end
 
 
 
else
    
 RT.rt{1} = RT1.rt;
 RT.laten{1} = RT1.laten;
      try 
         RT.misslaten{1} = RT1.misslaten;
     catch
          RT.misslaten{1} = [];
     end
 
 if iscell(RT2.rt) 
     RT.rt(2:2+l2) = RT2.rt;
     RT.laten(2:2+l2) = RT2.laten;
     try 
         RT.misslaten(2:2+l2) = RT2.misslaten;
     catch
          RT.misslaten{2:2+l2} = [];
     end
     
     
 else
     RT.rt{2} = RT2.rt;
     RT.laten{2} = RT2.laten;
     try 
         RT.misslaten(2) = RT2.misslaten;
     catch
          RT.misslaten{2} = [];
     end     
     
 end 
 
end



RT.nblock = RT1.nblock + RT2.nblock;
end