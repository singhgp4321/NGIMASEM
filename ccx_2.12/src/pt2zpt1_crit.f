!     
!     CalculiX - A 3-dimensional finite element program
!     Copyright (C) 1998-2015 Guido Dhondt
!     
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation(version 2);
!     
!     
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of 
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
!     GNU General Public License for more details.
!     
!     You should have received a copy of the GNU General Public License
!     along with this program; if not, write to the Free Software
!     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
!
!     calculate the maximal admissible pressure ratio pt2/pt1
!
!     1) assuming M2=1 for adiabatic respectively M2=1/dsqrt(kappa) 
!        for isotherm pipe choking 
!        M1 is calculated iteratively using a dichotomy scheme
!
!     2)the ratio of the critical pressure ratio  
!       Qred_1/Qred_2crit=Pt2/Pt1=D(M1)/D(M2_crit)
!       is computed 
!       [D(M)=M*(1+0.5*(kappa-1)*M)**(-0.5*(kappa+1)/(kappa-1))]
!       (general gas equation)
!
!     author: Yannick Muller
!   
      subroutine pt2zpt1_crit(pt2,pt1,Tt1,lambda,kappa,r,l,d,
     &     inv,pt2zpt1_c,Qred_crit,crit,icase,M1)
!     
      implicit none
!
      logical crit
!
      integer inv,icase,i
!     
      real*8 pt2,pt1,lambda,kappa,l,d,M1,pt2zpt1,pt2zpt1_c,
     &     km1,kp1,kp1zk,Tt1,r,xflow_crit,Qred_crit,fmin,
     &     f,fmax,M1_min,M1_max,lld
!
      intent(in) pt2,pt1,Tt1,lambda,kappa,r,l,d,
     &     inv,icase
!
      intent(inout) Qred_crit,crit,pt2zpt1_c
!
      crit=.false.
!
!     useful variables and constants
! 
      km1=kappa-1.d0
      kp1=kappa+1.d0
      kp1zk=kp1/kappa
      lld=lambda*l/d
!
!     adiabatic case
!
      if(icase.eq.0) then
!     
!        computing M1 using dichotomy method (dividing the interval with the function
!        root iteratively by 2)
!     
         i=1
!
         M1_min=0.001d0
         M1_max=1
!
         fmin=(1.d0-M1_min**2)*(kappa*M1_min**2)**(-1)
     &        +0.5d0*kp1zk*log((0.5d0*kp1)*M1_min**2
     &        *(1+0.5d0*km1*M1_min**2)**(-1))-lld
!     
         fmax=(1.d0-M1_max**2)*(kappa*M1_max**2)**(-1)
     &        +0.5d0*kp1zk*log((0.5d0*kp1)*M1_max**2
     &        *(1+0.5d0*km1*M1_max**2)**(-1))-lld
         do
            i=i+1
            M1=(M1_min+M1_max)*0.5d0
!     
            f=(1.d0-M1**2)*(kappa*M1**2)**(-1)
     &           +0.5d0*kp1zk*log((0.5d0*kp1)*M1**2
     &           *(1+0.5d0*km1*M1**2)**(-1))-lld
!     
            if(abs(f).le.1E-6) then
               exit
            endif
            if(i.gt.50) then
               exit
            endif
!     
            if(fmin*f.le.0.d0) then
               M1_max=M1
               fmax=f
            else
               M1_min=M1
               fmin=f
            endif
         enddo
!     
         Pt2zpt1_c=M1*(0.5d0*kp1)**(0.5*kp1/km1)
     &        *(1+0.5d0*km1*M1**2)**(-0.5d0*kp1/km1)
!     
!     isothermal case
!
      elseif (icase.eq.1) then
!     
!        computing M1 using dichotomy method for choked conditions M2=1/dsqrt(kappa)
!        (1.d0-kappa*M1**2)/(kappa*M1**2)+log(kappa*M1**2)-lambda*l/d=0
!     
         i=1
!     
         M1_min=0.1d0
         M1_max=1/dsqrt(kappa)
!     
         fmin=(1.d0-kappa*M1_min**2)/(kappa*M1_min**2)
     &        +log(kappa*M1_min**2)-lambda*l/d
!     
         fmax=(1.d0-kappa*M1_max**2)/(kappa*M1_max**2)
     &        +log(kappa*M1_max**2)-lambda*l/d
!     
         do
            i=i+1
            M1=(M1_min+M1_max)*0.5d0
!     
            f=(1.d0-kappa*M1**2)/(kappa*M1**2)
     &           +log(kappa*M1**2)-lambda*l/d
!     
            if((abs(f).le.1E-5).or.(i.ge.50)) then
               exit
            endif
!     
            if(fmin*f.le.0.d0) then
               M1_max=M1
               fmax=f
            else
               M1_min=M1
               fmin=f
            endif
         enddo
!     
!        computing the critical pressure ratio in the isothermal case
!        pt=A*dsqrt(kappa)/(xflow*dsqrt(kappa Tt))*
!           M*(1+0.5d0*(kappa-1)M**2)**(-0.5d0*(kappa+1)/(kappa-1))
!        and forming the pressure ratio between inlet and outlet(choked)
!     
c         Pt2zPt1_c=dsqrt(Tt2/Tt1)*M1*dsqrt(kappa)*((1+0.5d0*km1/kappa)
c     &        /(1+0.5d0*km1*M1**2))**(0.5d0*(kappa+1)/km1)
         Pt2zPt1_c=M1*dsqrt(kappa)*((1+0.5d0*km1/kappa)
     &        /(1+0.5d0*km1*M1**2))**(0.5d0*(kappa+1)/km1+0.5d0)
!     
      endif
!     
      pt2zpt1=pt2/pt1
      if(Pt2zPt1.le.Pt2zPt1_c) then
         crit=.true.
      endif
!     
      Qred_crit=M1*dsqrt(kappa/r)
     &     *(1+0.5d0*km1*M1**2)**(-0.5d0*kp1/km1)
!     
      return
      end      
      
      
