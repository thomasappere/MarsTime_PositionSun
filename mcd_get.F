      program mcd_get
      implicit none

c     ---------------------------------------------------------
c     This is a program that can be used along with 
c     the companion profils_mcd_idl.pro
c     to calculate profiles of atmospheric variable
c     At various space and time coordinate using IDL
c     It compiles just like test_emcd.F with any f77 compiler
c     F. Forget, 2005

c     ---------------------------------------------------------
c***  WARNING: please provide the path to the MCD data here :
      character*26 dset
      data dset/'EMCD_DATA/'/
c     ---------------------------------------------------------


      integer  nzmax, nz,ncoord,iz, icoord
      parameter (nzmax=500) !  max number of layers 
      integer ikey
      integer zkey ! flag to choose the type of z coordinates
      real latdeg,londeg  ! degree
      double precision  xlat,xlon  ! radian
      double precision  xz(nzmax) ! z coordinate 
      double precision ls, lt
      double precision pres,ro,temp,typper(2),u,v
      double precision meanvar(5),extvar(50),seedout,invar
      double precision tempz(nzmax),tempsig
      double precision logsigz(nzmax),logsigma_ref(nzmax),sigma_ref
      integer  dust
      integer ierr, uin, uout
      logical init_atm
      data init_atm /.true./
      double precision xdate 

c     Opening interface files
c     -----------------------
      uin = 73
      open(uin,file='idl2fort.asc')   
      uout = 74
      open(uout,file='fort2idl.asc')   

c     reading input interface files wrote by IDL
c     ------------------------------------------
c     dust is the Scenarios : MY24=1,2,3 storm=4,5,6 warm=7 cold=8
      read(uin,*) dust
c     zkey : kind of xz: 1:zradius 2:zareoid 3:zsurface 4:pressure
      read(uin,*) zkey
c     Dimension of space and time requested block of data
      read(uin,*) ncoord,nz !array dimension 
c     Reading the standard sigma coordinate in which
c     output are interpolated
      do iz=1, nz
        read(uin,*) sigma_ref
        logsigma_ref(iz) = -log(sigma_ref)
        xz(iz) = 1d4 * logsigma_ref(iz)
      enddo

      if(nz.gt.nzmax) stop'you need to increase nzmax' 

      typper(1)=1   ! perturbation  (mean=1 large=2 small=3. both=4) ;
      typper(2)= 0  ! seed number for perturbation
      invar=16000   !  Select small-scale perturbation wavelength (m)
      ikey=1

c     Space and time coordinate of block :
      do icoord =1, ncoord
         read(uin,*) latdeg, londeg, ls, xdate

         xlat = latdeg * 3.1415927/180.
         xlon = londeg * 3.1415927/180.

c        Runnning atmemcd
c        ----------------
c         Reading Database :
         do iz=1, nz          
            call atmemcd(xz(iz),zkey,xlat,xlon,xdate,dset,dust,
     &           typper,invar, init_atm,seedout,ikey,
     &           pres,ro,temp,u,v,meanvar,extvar,ierr)
            logsigz(iz) = -log(pres/extvar(19))
            tempz(iz) = temp
         end do

c     
c     Interpolation of temperature profile in sigma_ref coordinate:
      do iz=1,nz
        call interpolf(logsigma_ref(iz),tempsig,logsigz,tempz,nz) 
        write(uout,*) tempsig 
      end do
      write(uout,*) extvar(15) ! surface temperature
          ! change here for any desired field (see the list in atmemcd)
          ! here the dust opacity as an example
          write(uout,*) extvar(36) ! dust OD
      end do
      write(uout,*) extvar(5)
      write(uout,*) extvar(6)
      close(uin)
      close(uout)
      end

c **********************************************************************
      Subroutine interpolf(x,y,xd,yd,nd)
 
c******************************************************
c   SUBROUTINE   (interpol)
c interpolation, give y = f(x) with array xd,yd known, size nd
 
c  Version with CONSTANT values oustide limits
c**********************************************************
 
 
c Variable declaration
c --------------------
c  Arguments :
      double precision x,y
      double precision xd(*),yd(*)
      integer nd
c  internal
      integer i,j
 
c run
c ---
 
      y=0.
      if ((x.le.xd(1)).and.(x.le.xd(nd))) then
        if (xd(1).lt.xd(nd)) y = yd(1)
        if (xd(1).ge.xd(nd)) y = yd(nd)
      else if ((x.ge.xd(1)).and.(x.ge.xd(nd))) then
        if (xd(1).lt.xd(nd)) y = yd(nd)
        if (xd(1).ge.xd(nd)) y = yd(1)
        y = yd (nd)
      else
        do i=1,nd-1
         if ( ( (x.ge.xd(i)).and.(x.lt.xd(i+1)) )
     &     .or. ( (x.le.xd(i)).and.(x.gt.xd(i+1)) ) ) then
           y=yd(i)+(x-xd(i))*(yd(i+1)-yd(i))/(xd(i+1)-xd(i))
           goto 99
         end if
        end do
      end if
 99   continue
 
      end


