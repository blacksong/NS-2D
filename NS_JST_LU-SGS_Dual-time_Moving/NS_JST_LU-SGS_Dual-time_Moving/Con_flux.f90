subroutine Con_flux        !convective flux
    implicit none 
    integer::i
    integer::ncl,ncr                                       !the number of the left and the right cell
    real(8)::rou0,c0                                  !the reference value to calculate boundaries's flow information
    !real(8)::U_av(6)!
    real(8)::c_av              
    real(8)::W_av(5)                                  !conservative variables on any edge
    real(8)::ux,uy,Vn                                        !define as U(2,:)*dy+U(3,:)*dx
    real(8)::Ma                                       !mach number on any edge
    real(8)::mu_av
    
    !write(*,*)  "Convective_flux"
    
    !set Fc to zero
   
    Fc = 0.0
    lamda_c = 0.0
    lamda_v = 0.0
    
    do i = 1,nedges
        ncl=iedge(3,i)
        ncr=iedge(4,i)
            
        ux =  U_av(2,i) - 0.5 * ( U_Rot(1,iedge(1,i)) + U_Rot(1,iedge(2,i)) )
        uy =  U_av(3,i) - 0.5 * ( U_Rot(2,iedge(1,i)) + U_Rot(2,iedge(2,i)) )
        Vn = ux* vector(1,i)   + uy * vector(2,i) 
            
        W_av(1)=U_av(1,i)
        W_av(2)=U_av(1,i)*U_av(2,i)
        W_av(3)=U_av(1,i)*U_av(3,i)
        W_av(5)=U_av(5,i)/(gamma-1) + U_av(1,i)*( U_av(2,i)**2+U_av(3,i)**2 )/2.0    !rouE 
        W_av(5)=W_av(5)+U_av(5,i)   !rouH     
        
         !propagation speed on every edge
        c_av=sqrt( U_av(5,i)*gamma/U_av(1,i) )
        alf(i)= abs(Vn) + c_av * ds(i)
        
        mu_av = 1.45*U_av(6,i)**(3.0/2)/(U_av(6,i)+110.0) *1.0E-6
        alf_v(i)= max( 4.0/3/U_av(1,i),gamma/U_av(1,i) ) *( mu_av/PrL )*ds(i)**2
        
        if ( ncr .GT. 0) then
            !the left cell plus the convective flux
            Fc(1,ncl)= Fc(1,ncl) + Vn*W_av(1)
            Fc(2,ncl)= Fc(2,ncl) + Vn*W_av(2) + U_av(5,i)*vector(1,i)
            Fc(3,ncl)= Fc(3,ncl) + Vn*W_av(3) + U_av(5,i)*vector(2,i)
            Fc(5,ncl)= Fc(5,ncl) + Vn*W_av(5)
            !the right cell subtract the convective flux
            Fc(1,ncr)= Fc(1,ncr) - Vn*W_av(1)
            Fc(2,ncr)= Fc(2,ncr) -( Vn*W_av(2) + U_av(5,i)*vector(1,i) )
            Fc(3,ncr)= Fc(3,ncr) -( Vn*W_av(3) + U_av(5,i)*vector(2,i) )
            Fc(5,ncr)= Fc(5,ncr) - Vn*W_av(5)    
           
            lamda_c(ncl) = lamda_c(ncl) + alf(i)
            lamda_c(ncr) = lamda_c(ncr) + alf(i)
            lamda_v(ncl) = lamda_v(ncl) + alf_v(i)/vol(ncl)
            lamda_v(ncr) = lamda_v(ncr) + alf_v(i)/vol(ncr)
        else
            !the left cell plus the convective flux
            Fc(1,ncl)= Fc(1,ncl) + Vn*W_av(1)
            Fc(2,ncl)= Fc(2,ncl) + Vn*W_av(2) + U_av(5,i)*vector(1,i)
            Fc(3,ncl)= Fc(3,ncl) + Vn*W_av(3) + U_av(5,i)*vector(2,i)
            Fc(5,ncl)= Fc(5,ncl) + Vn*W_av(5) 
            
            lamda_c(ncl) = lamda_c(ncl) + alf(i)
            lamda_v(ncl) = lamda_v(ncl) + alf_v(i)/vol(ncl)
            
        end if
        
       
    end do
    
end subroutine

    