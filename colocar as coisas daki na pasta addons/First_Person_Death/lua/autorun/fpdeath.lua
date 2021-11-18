/*//////////////////////////////////////////////
//////	Jinto gets full credit for this code 	/////
/////////////////////////////////////////////*/


 // server
 //If you're hosting a server and have this, but don't want to send it to joining players, comment out the lines between point1 and point2
 //point1
 if( SERVER ) then
  
     AddCSLuaFile( "autorun/fpdeath.lua" );
  
end
//point2
  
  
 // client
 if( CLIENT ) then
  
     local function CalcView( pl, origin, angles, fov )
   
         // get their ragdoll
       local ragdoll = pl:GetRagdollEntity();
       if( !ragdoll || ragdoll == NULL || !ragdoll:IsValid() ) then return; end
       
        // find the eyes
        local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) );
        
         // setup our view
         local view = {
             origin = eyes.Pos,
             angles = eyes.Ang,
			 fov = 90, 
         };
        
          //
         return view;
     
      end
      hook.Add( "CalcView", "DeathView", CalcView );
      
       //
    
  end 
