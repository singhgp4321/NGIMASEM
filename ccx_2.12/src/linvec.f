!
!     CalculiX - A 3-dimensional finite element program
!              Copyright (C) 1998-2015 Guido Dhondt
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
      subroutine linvec(vec,konl,nope,jj,vecl,istart,iend)
!
!     calculates a trilinear approximation to the quadratic interpolation
!     of the temperatures in a C3D20 element (full integration). A
!     quadratic interpolation of the temperatures leads to quadratic
!     thermal stresses, which cannot be handled by the elements 
!     displacement functions (which lead to linear stresses). Thus,
!     the temperatures are approximated by a trilinear function.
!
      implicit none
!
      integer konl(20),nope,jj,i1,j,istart,iend
!
      real*8 vec(istart:iend,*),vecl(3),a20l(20,27)
!                        
      a20l=reshape((
     &/-0.088729832,-0.240369600,-0.059630393,-0.240369600,-0.240369600,
     & -0.059630393,-0.011270159,-0.059630393, 0.524865555, 0.066666663,
     &  0.066666663, 0.524865555, 0.066666663, 0.008467776, 0.008467776,
     &  0.066666663, 0.524865555, 0.066666663, 0.008467776, 0.066666663,
     & -0.164549715,-0.164549715,-0.149999995,-0.149999995,-0.149999995,
     & -0.149999995,-0.035450279,-0.035450279, 0.524865544, 0.295766106,
     &  0.066666668, 0.295766106, 0.066666668, 0.037567223, 0.008467777,
     &  0.037567223, 0.295766106, 0.295766106, 0.037567223, 0.037567223,
     & -0.240369600,-0.088729832,-0.240369600,-0.059630393,-0.059630393,
     & -0.240369600,-0.059630393,-0.011270159, 0.524865555, 0.524865555,
     &  0.066666663, 0.066666663, 0.066666663, 0.066666663, 0.008467776,
     &  0.008467776, 0.066666663, 0.524865555, 0.066666663, 0.008467776,
     & -0.164549715,-0.149999995,-0.149999995,-0.164549715,-0.149999995,
     & -0.035450279,-0.035450279,-0.149999995, 0.295766106, 0.066666668,
     &  0.295766106, 0.524865544, 0.037567223, 0.008467777, 0.037567223,
     &  0.066666668, 0.295766106, 0.037567223, 0.037567223, 0.295766106,
     & -0.157274855,-0.157274855,-0.157274855,-0.157274855,-0.092725137,
     & -0.092725137,-0.092725137,-0.092725137, 0.295766105, 0.295766105,
     &  0.295766105, 0.295766105, 0.037567224, 0.037567224, 0.037567224,
     &  0.037567224, 0.166666664, 0.166666664, 0.166666664, 0.166666664,
     & -0.149999995,-0.164549715,-0.164549715,-0.149999995,-0.035450279,
     & -0.149999995,-0.149999995,-0.035450279, 0.295766106, 0.524865544,
     &  0.295766106, 0.066666668, 0.037567223, 0.066666668, 0.037567223,
     &  0.008467777, 0.037567223, 0.295766106, 0.295766106, 0.037567223,
     & -0.240369600,-0.059630393,-0.240369600,-0.088729832,-0.059630393,
     & -0.011270159,-0.059630393,-0.240369600, 0.066666663, 0.066666663,
     &  0.524865555, 0.524865555, 0.008467776, 0.008467776, 0.066666663,
     &  0.066666663, 0.066666663, 0.008467776, 0.066666663, 0.524865555,
     & -0.149999995,-0.149999995,-0.164549715,-0.164549715,-0.035450279,
     & -0.035450279,-0.149999995,-0.149999995, 0.066666668, 0.295766106,
     &  0.524865544, 0.295766106, 0.008467777, 0.037567223, 0.066666668,
     &  0.037567223, 0.037567223, 0.037567223, 0.295766106, 0.295766106,
     & -0.059630393,-0.240369600,-0.088729832,-0.240369600,-0.011270159,
     & -0.059630393,-0.240369600,-0.059630393, 0.066666663, 0.524865555,
     &  0.524865555, 0.066666663, 0.008467776, 0.066666663, 0.066666663,
     &  0.008467776, 0.008467776, 0.066666663, 0.524865555, 0.066666663,
     & -0.164549715,-0.149999995,-0.035450279,-0.149999995,-0.164549715,
     & -0.149999995,-0.035450279,-0.149999995, 0.295766106, 0.037567223,
     &  0.037567223, 0.295766106, 0.295766106, 0.037567223, 0.037567223,
     &  0.295766106, 0.524865544, 0.066666668, 0.008467777, 0.066666668,
     & -0.157274855,-0.157274855,-0.092725137,-0.092725137,-0.157274855,
     & -0.157274855,-0.092725137,-0.092725137, 0.295766105, 0.166666664,
     &  0.037567224, 0.166666664, 0.295766105, 0.166666664, 0.037567224,
     &  0.166666664, 0.295766105, 0.295766105, 0.037567224, 0.037567224,
     & -0.149999995,-0.164549715,-0.149999995,-0.035450279,-0.149999995,
     & -0.164549715,-0.149999995,-0.035450279, 0.295766106, 0.295766106,
     &  0.037567223, 0.037567223, 0.295766106, 0.295766106, 0.037567223,
     &  0.037567223, 0.066666668, 0.524865544, 0.066666668, 0.008467777,
     & -0.157274855,-0.092725137,-0.092725137,-0.157274855,-0.157274855,
     & -0.092725137,-0.092725137,-0.157274855, 0.166666664, 0.037567224,
     &  0.166666664, 0.295766105, 0.166666664, 0.037567224, 0.166666664,
     &  0.295766105, 0.295766105, 0.037567224, 0.037567224, 0.295766105,
     & -0.124999996,-0.124999996,-0.124999996,-0.124999996,-0.124999996,
     & -0.124999996,-0.124999996,-0.124999996, 0.166666664, 0.166666664,
     &  0.166666664, 0.166666664, 0.166666664, 0.166666664, 0.166666664,
     &  0.166666664, 0.166666664, 0.166666664, 0.166666664, 0.166666664,
     & -0.092725137,-0.157274855,-0.157274855,-0.092725137,-0.092725137,
     & -0.157274855,-0.157274855,-0.092725137, 0.166666664, 0.295766105,
     &  0.166666664, 0.037567224, 0.166666664, 0.295766105, 0.166666664,
     &  0.037567224, 0.037567224, 0.295766105, 0.295766105, 0.037567224,
     & -0.149999995,-0.035450279,-0.149999995,-0.164549715,-0.149999995,
     & -0.035450279,-0.149999995,-0.164549715, 0.037567223, 0.037567223,
     &  0.295766106, 0.295766106, 0.037567223, 0.037567223, 0.295766106,
     &  0.295766106, 0.066666668, 0.008467777, 0.066666668, 0.524865544,
     & -0.092725137,-0.092725137,-0.157274855,-0.157274855,-0.092725137,
     & -0.092725137,-0.157274855,-0.157274855, 0.037567224, 0.166666664,
     &  0.295766105, 0.166666664, 0.037567224, 0.166666664, 0.295766105,
     &  0.166666664, 0.037567224, 0.037567224, 0.295766105, 0.295766105,
     & -0.035450279,-0.149999995,-0.164549715,-0.149999995,-0.035450279,
     & -0.149999995,-0.164549715,-0.149999995, 0.037567223, 0.295766106,
     &  0.295766106, 0.037567223, 0.037567223, 0.295766106, 0.295766106,
     &  0.037567223, 0.008467777, 0.066666668, 0.524865544, 0.066666668,
     & -0.240369600,-0.059630393,-0.011270159,-0.059630393,-0.088729832,
     & -0.240369600,-0.059630393,-0.240369600, 0.066666663, 0.008467776,
     &  0.008467776, 0.066666663, 0.524865555, 0.066666663, 0.066666663,
     &  0.524865555, 0.524865555, 0.066666663, 0.008467776, 0.066666663,
     & -0.149999995,-0.149999995,-0.035450279,-0.035450279,-0.164549715,
     & -0.164549715,-0.149999995,-0.149999995, 0.066666668, 0.037567223,
     &  0.008467777, 0.037567223, 0.524865544, 0.295766106, 0.066666668,
     &  0.295766106, 0.295766106, 0.295766106, 0.037567223, 0.037567223,
     & -0.059630393,-0.240369600,-0.059630393,-0.011270159,-0.240369600,
     & -0.088729832,-0.240369600,-0.059630393, 0.066666663, 0.066666663,
     &  0.008467776, 0.008467776, 0.524865555, 0.524865555, 0.066666663,
     &  0.066666663, 0.066666663, 0.524865555, 0.066666663, 0.008467776,
     & -0.149999995,-0.035450279,-0.035450279,-0.149999995,-0.164549715,
     & -0.149999995,-0.149999995,-0.164549715, 0.037567223, 0.008467777,
     &  0.037567223, 0.066666668, 0.295766106, 0.066666668, 0.295766106,
     &  0.524865544, 0.295766106, 0.037567223, 0.037567223, 0.295766106,
     & -0.092725137,-0.092725137,-0.092725137,-0.092725137,-0.157274855,
     & -0.157274855,-0.157274855,-0.157274855, 0.037567224, 0.037567224,
     &  0.037567224, 0.037567224, 0.295766105, 0.295766105, 0.295766105,
     &  0.295766105, 0.166666664, 0.166666664, 0.166666664, 0.166666664,
     & -0.035450279,-0.149999995,-0.149999995,-0.035450279,-0.149999995,
     & -0.164549715,-0.164549715,-0.149999995, 0.037567223, 0.066666668,
     &  0.037567223, 0.008467777, 0.295766106, 0.524865544, 0.295766106,
     &  0.066666668, 0.037567223, 0.295766106, 0.295766106, 0.037567223,
     & -0.059630393,-0.011270159,-0.059630393,-0.240369600,-0.240369600,
     & -0.059630393,-0.240369600,-0.088729832, 0.008467776, 0.008467776,
     &  0.066666663, 0.066666663, 0.066666663, 0.066666663, 0.524865555,
     &  0.524865555, 0.066666663, 0.008467776, 0.066666663, 0.524865555,
     & -0.035450279,-0.035450279,-0.149999995,-0.149999995,-0.149999995,
     & -0.149999995,-0.164549715,-0.164549715, 0.008467777, 0.037567223,
     &  0.066666668, 0.037567223, 0.066666668, 0.295766106, 0.524865544,
     &  0.295766106, 0.037567223, 0.037567223, 0.295766106, 0.295766106,
     & -0.011270159,-0.059630393,-0.240369600,-0.059630393,-0.059630393,
     & -0.240369600,-0.088729832,-0.240369600, 0.008467776, 0.066666663,
     &  0.066666663, 0.008467776, 0.066666663, 0.524865555, 0.524865555,
     &  0.066666663, 0.008467776, 0.066666663, 0.524865555, 0.066666663/
     &  ),(/20,27/))
!
      do i1=1,nope
         do j=1,3
            vecl(j)=vecl(j)+a20l(i1,jj)*vec(j,konl(i1))
         enddo
      enddo
!     
      return
      end
