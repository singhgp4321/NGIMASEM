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
      subroutine createialdesi(ndesi,nodedesi,iponoel,inoel,istartdesi,
     &                         ialdesi)
!
      implicit none
!
      integer ndesi,node,nodedesi(*),iponoel(*),inoel(2,*),
     &   istartdesi(*),ialdesi(*),ifree,index,i
!
!     determining the elements belonging to a given design
!     variable i. They are stored in ialdesi(istartdesi(i))..
!     ...up to..... ialdesi(istartdesi(i+1)-1)
!
      ifree=1
      do i=1,ndesi
         istartdesi(i)=ifree
         node=nodedesi(i)
         index=iponoel(node)
         do
            if(index.eq.0) exit
            ialdesi(ifree)=inoel(1,index)
            ifree=ifree+1
            index=inoel(2,index)
         enddo
      enddo
      istartdesi(ndesi+1)=ifree
!
      return
      end
