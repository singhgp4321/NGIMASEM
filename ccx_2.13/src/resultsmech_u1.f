!
!     CalculiX - A 3-dimensional finite element program
!              Copyright (C) 1998-2017 Guido Dhondt
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
      subroutine resultsmech_u1(co,kon,ipkon,lakon,ne,v,
     &  stx,elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,
     &  ielmat,ielorien,norien,orab,ntmat_,t0,t1,ithermal,prestr,
     &  iprestr,eme,iperturb,fn,iout,qa,vold,nmethod,
     &  veold,dtime,time,ttime,plicon,nplicon,plkcon,nplkcon,
     &  xstateini,xstiff,xstate,npmat_,matname,mi,ielas,icmd,
     &  ncmat_,nstate_,stiini,vini,ener,eei,enerini,istep,iinc,
     &  reltime,calcul_fn,calcul_qa,calcul_cauchy,nener,
     &  ikin,nal,ne0,thicke,emeini,i,ielprop,prop)
!
!     calculates nal,qa,fn,xstiff,ener,eme,eei,stx for user element 1
!
!     Yunhua Luo, An Efficient 3D Timoshenko Beam Element with
!     Consistent Shape Functions, Adv. Theor. Appl. Mech., Vol. 1,
!     2008, no. 3, 95-106
!
      implicit none
!
      character*8 lakon(*)
      character*80 amat,matname(*)
!
      integer kon(*),konl(26),mi(*),
     &  nelcon(2,*),nrhcon(*),nalcon(2,*),ielmat(mi(3),*),
     &  ielorien(mi(3),*),ntmat_,ipkon(*),ne0,
     &  istep,iinc,ne,mattyp,ithermal(2),iprestr,i,j,k,m1,m2,jj,
     &  i1,kk,nener,indexe,nope,norien,iperturb(*),iout,
     &  nal,icmd,ihyper,nmethod,kode,imat,iorien,ielas,
     &  istiff,ncmat_,nstate_,ikin,ielprop(*),
     &  nplicon(0:ntmat_,*),nplkcon(0:ntmat_,*),npmat_,calcul_fn,
     &  calcul_cauchy,calcul_qa,index,node
!
      real*8 co(3,*),v(0:mi(2),*),stiini(6,mi(1),*),
     &  stx(6,mi(1),*),xl(3,26),vl(0:mi(2),26),stre(6),prop(*),
     &  elcon(0:ncmat_,ntmat_,*),rhcon(0:1,ntmat_,*),
     &  alcon(0:6,ntmat_,*),vini(0:mi(2),*),
     &  alzero(*),orab(7,*),elas(21),rho,fn(0:mi(2),*),
     &  q(0:mi(2),26),t0(*),t1(*),prestr(6,mi(1),*),eme(6,mi(1),*),
     &  vold(0:mi(2),*),eloc(9),elconloc(21),eth(6),coords(3),
     &  ener(mi(1),*),emec(6),eei(6,mi(1),*),enerini(mi(1),*),
     &  veold(0:mi(2),*),e,un,um,tt,dl,qa(*),t0l,t1l,dtime,time,ttime,
     &  plicon(0:2*npmat_,ntmat_,*),plkcon(0:2*npmat_,ntmat_,*),
     &  xstiff(27,mi(1),*),xstate(nstate_,mi(1),*),plconloc(802),
     &  xstateini(nstate_,mi(1),*),tm(3,3),a,reltime,
     &  thicke(mi(3),*),emeini(6,mi(1),*),aly,alz,bey,bez,xi(2),
     &  vlp(6,2),xi11,xi12,xi22,xk,offset1,offset2,e1(3),e2(3),e3(3)
!
      intent(in) co,kon,ipkon,lakon,ne,v,
     &  elcon,nelcon,rhcon,nrhcon,alcon,nalcon,alzero,
     &  ielmat,ielorien,norien,orab,ntmat_,t0,t1,ithermal,prestr,
     &  iprestr,iperturb,iout,vold,nmethod,
     &  veold,dtime,time,ttime,plicon,nplicon,plkcon,nplkcon,
     &  xstateini,xstate,npmat_,matname,mi,ielas,icmd,
     &  ncmat_,nstate_,stiini,vini,enerini,istep,iinc,
     &  reltime,calcul_fn,calcul_qa,calcul_cauchy,nener,
     &  ikin,ne0,thicke,emeini,i,ielprop,prop
!
      intent(inout) nal,qa,fn,xstiff,ener,eme,eei,stx
!
      nope=2
!
!     q contains the nodal forces per element; initialization of q
!
      if((iperturb(1).ge.2).or.((iperturb(1).le.0).and.(iout.lt.1))) 
     &     then
         do m1=1,nope
            do m2=0,mi(2)
               q(m2,m1)=fn(m2,konl(m1))
            enddo
         enddo
      endif
!
      indexe=ipkon(i)
!
!     material and orientation
!
      imat=ielmat(1,i)
      amat=matname(imat)
      if(norien.gt.0) then
         iorien=ielorien(1,i)
      else
         iorien=0
      endif
      if(iorien.gt.0) then
         write(*,*) '*ERROR in resultsmech_u1: no orientation'
         write(*,*) '       calculation for this type of element'
         call exit(201)
      endif
!     
      if(nelcon(1,imat).lt.0) then
         ihyper=1
      else
         ihyper=0
      endif
!
!     properties of the cross section
!
      index=ielprop(i)
      a=prop(index+1)
      xi11=prop(index+2)
      xi12=prop(index+3)
      xi22=prop(index+4)
      xk=prop(index+5)
      e2(1)=prop(index+6)
      e2(2)=prop(index+7)
      e2(3)=prop(index+8)
      offset1=prop(index+9)
      offset2=prop(index+10)
!
      if(dabs(xi12).gt.0.d0) then
         write(*,*) '*ERROR in resultsmech_u1: no nonzero cross moment'
         write(*,*) '       of inertia for this type of element'
         call exit(201)
      endif
!
      if(dabs(offset1).gt.0.d0) then
         write(*,*) '*ERROR in resultsmech_u1: no offset in 1-direction'
         write(*,*) '       for this type of element'
         call exit(201)
      endif
!
      if(dabs(offset2).gt.0.d0) then
         write(*,*) '*ERROR in resultsmech_u1: no offset in 2-direction'
         write(*,*) '       for this type of element'
         call exit(201)
      endif
!
!     computation of the coordinates and displacements of the local nodes
!
      do k=1,nope
         konl(k)=kon(indexe+k)
         do j=1,3
            xl(j,k)=co(j,konl(k))
            vl(j,k)=v(j,konl(k))
         enddo
      enddo
!
!     local axes e1-e2-e3  (e2 is given by the user (in the input deck
!     this is called e1), e1 is parallel to the beam axis)
!
      do j=1,3
         e1(j)=xl(j,2)-xl(j,1)
      enddo
!
      dl=dsqrt(e1(1)*e1(1)+e1(2)*e1(2)+e1(3)*e1(3))
!
      do j=1,3
         e1(j)=e1(j)/dl
      enddo
!
!     e3 = e1 x e2
!
      e3(1)=e1(2)*e2(3)-e1(3)*e2(2)
      e3(2)=e1(3)*e2(1)-e1(1)*e2(3)
      e3(3)=e1(1)*e2(2)-e1(2)*e2(1)
!
!     transformation matrix from the global into the local system
!
      do j=1,3
         tm(1,j)=e1(j)
         tm(2,j)=e2(j)
         tm(3,j)=e3(j)
      enddo
!
!     calculating the temperature in the integration
!     point
!     
      t0l=0.d0
      t1l=0.d0
      if(ithermal(1).eq.1) then
         do i1=1,nope
            t0l=t0l+t0(konl(i1))/2.d0
            t1l=t1l+t1(konl(i1))/2.d0
         enddo
      elseif(ithermal(1).ge.2) then
         write(*,*) '*ERROR in resultsmech_u1: no thermal'
         write(*,*) '       calculation for this type of element'
         call exit(201)
      endif
      tt=t1l-t0l
!     
      kode=nelcon(1,imat)
!
      if(kode.eq.2) then
         mattyp=1
      else
         mattyp=0
      endif
!     
!     material data and local stiffness matrix
!     
      istiff=0
      call materialdata_me(elcon,nelcon,rhcon,nrhcon,alcon,nalcon,
     &     imat,amat,iorien,coords,orab,ntmat_,elas,rho,
     &     i,ithermal,alzero,mattyp,t0l,t1l,
     &     ihyper,istiff,elconloc,eth,kode,plicon,
     &     nplicon,plkcon,nplkcon,npmat_,
     &     plconloc,mi(1),dtime,kk,
     &     xstiff,ncmat_)
!
!     correcting the thermal strains
!
      do k=2,6
         eth(k)=0.d0
      enddo
!     
      if(mattyp.eq.1) then
         e=elconloc(1)
         un=elconloc(2)
         um=e/(1.d0+un)
         um=um/2.d0
      else
         write(*,*) '*ERROR in resultsmech_u1: no anisotropic material'
         write(*,*) '       calculation for this type of element'
         call exit(201)
      endif
!
!     calculating the local displacement and rotation values
!
      do k=1,nope
         node=kon(indexe+k)
         do j=1,3
            vl(j,k)=tm(j,1)*v(1,node)
     &             +tm(j,2)*v(2,node)
     &             +tm(j,3)*v(3,node)
            vl(j+3,k)=tm(j,1)*v(4,node)
     &               +tm(j,2)*v(5,node)
     &               +tm(j,3)*v(6,node)
         enddo
      enddo
!
      xi(1)=0.d0
      xi(2)=1.d0
!
      aly=12.d0*e*xi11/(xk*um*a*dl*dl)
      alz=12.d0*e*xi22/(xk*um*a*dl*dl)
      bey=1.d0/(1.d0-aly)
      bez=1.d0/(1.d0-alz)
!
      do jj=1,nope
!
!        calculating the derivative of the local displacement and
!        rotation values
!
         vlp(1,jj)=(-vl(1,1)+vl(1,2))/dl
         vlp(2,jj)=
     &     bey*(6.d0*xi(jj)**2-3.d0*xi(jj)+aly*xi(jj))/dl*vl(2,1)+
     &    bey*(3.d0*xi(jj)**2+(aly-4.d0)*xi(jj)+(1.d0-aly/2.d0))*vl(6,1)
     &    +bey*(-6.d0*xi(jj)**2+6.d0*xi(jj)-aly)/dl*vl(2,2)
     &    +bey*(3.d0*xi(jj)**2-(2.d0+aly)*xi(jj)+aly/2.d0)*vl(6,2)
         vlp(3,jj)=bez*(6.d0*xi(jj)*xi(jj)-6.d0*xi(jj)+alz)/dl*vl(3,1)+
     &    bez*(3.d0*xi(jj)**2+(alz-4.d0)*xi(jj)+(1.d0-alz/2.d0))*vl(5,1)
     &    +bez*(-6.d0*xi(jj)**2+6.d0*xi(jj)-alz)/dl*vl(3,2)
     &    +bez*(3.d0*xi(jj)**2-(2.d0+alz)*xi(jj)+alz/2.d0)*vl(5,2)
         vlp(4,jj)=(vl(4,2)-vl(4,1))/dl
         vlp(5,jj)=6.d0*bez*(2.d0*xi(jj)-1.d0)/(dl*dl)*vl(3,1)
     &           +bez*(6.d0*xi(jj)+(alz-4.d0))/dl*vl(5,1)
     &           +6.d0*bez*(-2.d0*xi(jj)+1.d0)/(dl*dl)*vl(3,2)
     &           +bez*(6.d0*xi(jj)-(alz+2))/dl*vl(5,2)
         vlp(6,jj)=6.d0*bey*(2.d0*xi(jj)-1.d0)/(dl*dl)*vl(2,1)
     &           +bey*(6.d0*xi(jj)+(aly-4.d0))/dl*vl(6,1)
     &           +6.d0*bey*(-2.d0*xi(jj)+1.d0)/(dl*dl)*vl(2,2)
     &           +bey*(6.d0*xi(jj)-(aly+2.d0))/dl*vl(6,2)
!
!        calculation of the strains
!
         eloc(1)=vlp(1,jj)
         eloc(2)=-vlp(6,jj)
         eloc(3)=vlp(5,jj)
         eloc(4)=vlp(2,jj)-vl(6,jj)
         eloc(5)=vlp(3,jj)+vl(5,jj)
         eloc(6)=vlp(4,jj)
!
!           determining the mechanical strain
!
         if(ithermal(1).ne.0) then
            do m1=2,6
               emec(m1)=eloc(m1)-eth(m1)
            enddo
         else
            do m1=1,6
               emec(m1)=eloc(m1)
            enddo
         endif
!
!        subtracting initial strains
!
         if(iprestr.ne.0) then
            write(*,*) '*ERROR in resultsmech_u1:'
            write(*,*) '       no initial strains allowed for'
            write(*,*) '       this user element'
            call exit(201)
         endif
!
!        calculating the section forces
!
         stre(1)=e*a*emec(1)
         stre(2)=e*xi11*emec(2)
         stre(3)=e*xi22*emec(3)
         stre(4)=xk*um*a*emec(4)
         stre(5)=xk*um*a*emec(5)
         stre(6)=xk*um*(xi11+xi22)*emec(6)
! 
!        updating the internal energy and mechanical strain
!
         if((iout.gt.0).or.(iout.eq.-2).or.(kode.le.-100).or.
     &        ((nmethod.eq.4).and.(iperturb(1).gt.1).and.
     &        (ithermal(1).le.1))) then
            if(ithermal(1).eq.0) then
               do m1=1,6
                  eth(m1)=0.d0
               enddo
            endif
            if(nener.eq.1) then
               ener(jj,i)=enerini(jj,i)+
     &              ((eloc(1)-eth(1)-emeini(1,jj,i))*
     &              (stre(1)+stiini(1,jj,i))+
     &              (eloc(2)-eth(2)-emeini(2,jj,i))*
     &              (stre(2)+stiini(2,jj,i))+
     &              (eloc(3)-eth(3)-emeini(3,jj,i))*
     &              (stre(3)+stiini(3,jj,i)))/2.d0+
     &         (eloc(4)-eth(4)-emeini(4,jj,i))*(stre(4)+stiini(4,jj,i))+
     &         (eloc(5)-eth(5)-emeini(5,jj,i))*(stre(5)+stiini(5,jj,i))+
     &         (eloc(6)-eth(6)-emeini(6,jj,i))*(stre(6)+stiini(6,jj,i))
            endif
            eme(1,jj,i)=eloc(1)-eth(1)
            eme(2,jj,i)=eloc(2)-eth(2)
            eme(3,jj,i)=eloc(3)-eth(3)
            eme(4,jj,i)=eloc(4)-eth(4)
            eme(5,jj,i)=eloc(5)-eth(5)
            eme(6,jj,i)=eloc(6)-eth(6)
         endif
!     
         if((iout.gt.0).or.(iout.eq.-2).or.(kode.le.-100)) then
!     
            eei(1,jj,i)=eloc(1)
            eei(2,jj,i)=eloc(2)
            eei(3,jj,i)=eloc(3)
            eei(4,jj,i)=eloc(4)
            eei(5,jj,i)=eloc(5)
            eei(6,jj,i)=eloc(6)
         endif
!
!        updating the kinetic energy
!     
         if(ikin.eq.1) then
            write(*,*) '*ERROR in resultsmech_u1:'
            write(*,*) '       no initial strains allowed for'
            write(*,*) '       this user element'
            call exit(201)
         endif
!     
         stx(1,jj,i)=stre(1)
         stx(2,jj,i)=stre(2)
         stx(3,jj,i)=stre(3)
         stx(4,jj,i)=stre(4)
         stx(5,jj,i)=stre(5)
         stx(6,jj,i)=stre(6)
!     
!     calculation of the global nodal forces
!     
         if(calcul_fn.eq.1)then
            node=kon(indexe+jj)
            do j=1,3
               fn(j,node)=fn(j,node)+tm(1,j)*stre(1)
     &              +tm(2,j)*stre(2)
     &              +tm(3,j)*stre(3)
               fn(j+3,node)=fn(j+3,node)+tm(1,j)*stre(4)
     &              +tm(2,j)*stre(5)
     &              +tm(3,j)*stre(6)
               enddo
         endif
      enddo
!
!     q contains the contributions to the nodal force in the nodes
!     belonging to the element at stake from other elements (elements
!     already treated). These contributions have to be
!     subtracted to get the contributions attributable to the element
!     at stake only
!
      if(calcul_qa.eq.1) then
         do m1=1,nope
            do m2=1,3
               qa(1)=qa(1)+dabs(fn(m2,konl(m1))-q(m2,m1))
            enddo
         enddo
         nal=nal+3*nope
      endif
!
      return
      end
