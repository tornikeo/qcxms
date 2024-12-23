```py

# it: int, 
#   when -1: M is equil
#   when  0: M is sampling? (what)
#   when >0: M+ fragm
# mdok: bool, Should log?

def md(it, 
    nuc: int, # num nuclei
    iat: list[int], # What?
    list_: list[int], # Atom list?

    fragat: ndarray,
    # ndarray [200, 10], int, 
    # 200 = 100 elements + 100 isotopes
    # 10 frags max per fragmentation event (sounds quite small?)

    nstep, ndump, mdump, nfrag, i, j, avdump, kdump, dump, # ints, logging steps?

    screendump,nadd,morestep,more,spin,fconst, # ???

    mchrg, # int molecular charge?

    xyz, grad, velo, axyz, # all float64 array [3, nuclei], 
    # xyz positions, grads?, velocity vectors and acceleration? vectors of nuclei
    velof, aspin, achrg, mass, # float64 [nuclei],
    
    fragm, fragT, # float64 [10,], max num frags allowed?

    tstep, tadd, eimp, aTlast, dtime, # Time control, all fp64 scalars

    # The rest of the gang:
    #   real(wp) :: T,Tav,Epav,Ekav,etempin,Tsoll,ttime
    #   real(wp) :: Epot,Eerror,Ekin,Edum,dum,etemp,Eav,fadd
    #   real(wp) :: Ekinstart
    #   real(wp) :: avspin(nuc),avchrg(nuc),avxyz(3,nuc)
    #   real(wp) :: store_avxyz(3,nuc)
    #   real(wp) ::  sca

    # CID stuff?

    #   real(wp) :: diff_cm(3),cm_out
    #   real(wp) :: cm(3),old_cm(3)
    #   real(wp) :: new_velo,new_temp
    #   real(wp) :: E_kin,E_kin_diff,summass
    #   real(wp) :: Ekin_new,tinit
    #   real(wp) :: E_int(10)
    
    # Exception flags?
    #   logical err1,err2
    #   logical ECP
    #   logical gradfail
    #   logical starting_md
    #   logical mdok,restart
 
    # ! Stuff for checking RMSD 
    # (RMSD? root mean square difference - chadgpt agrees - is it though?)
    # 
    # integer :: check_fragmented
    # integer :: cnt
    # integer :: iatf(nuc,10)
    # integer :: natf(10)
    # integer :: save_natf(10)
    # integer :: s1,s2, s3
    # !real(wp) :: normmass
    # !real(wp) :: cg(3,10,50)
    # real(wp) :: diff_cg(3,10,50)
    # real(wp),allocatable :: nxyz1(:,:)!(3,nuc)
    # real(wp),allocatable :: nxyz2(:,:)!(3,nuc)
    # real(wp) :: check_xyz(3,nuc)
    # real(wp) :: xyzf(3,nuc,10)
    # real(wp) :: rmsd_check (3,nuc,10,50)
    # real(wp) :: root_msd, rmsd_frag(10), highest_rmsd(10)
    # real(wp) :: gradient(3,nuc)
    # real(wp) :: trafo(3,3)
    # !type(fragment_info) :: frag
    # logical :: count_average = .false.

    # !Stuff for count start
    # integer :: cnt_start, start_cnt
    # integer :: cnt_steps
    # integer :: max_steps, add_steps

    *args, mdok):

    mdok = False
    nfrag = 1

    # status of fragments when run was ok (=0 is undefined)
    # 1: normal
    # 2: nothing happend for nfrag=2 for some time      
    fragstate=0 

    # it=-1 : equilibration GS, no dump
    # it= 0 : GS for generating starting points
    # it> 1 : frag. MD

    # Ekin is kinetic energy?
    
    # compute initial mol kinetic energy, total
    Ekin, Temp = ekinet(nuc, velo, mass, Ekin, Temp)

    if 0 < it < 9999 and etempin < 0: # This whole fkn block is nonsensical
    # This could just be a single max mul add
        etemp = setetemp(nfrag,eimp,etemp)
    else:
        etemp = etempin
    
    # Initialize Epotential ()
    try:
        Epot = egrad(true,nuc,xyz,iat,mchrg,spin,etemp,Epot,grad,achrg,aspin,ECP,gradfail)
    except GradFail:
        print("Grad failed")
    if Epot == 0:  # Why? is this a return code?
        return

    # Main MD loop
    for nstep in range(1, nmax):
        T = Ekin/(.5 * 3 * nuc * k_boltzmann) # Temperature in kelvin, scalar

        # Moving averages? Why no division? This is going to explode, no?
        Tav =Tav+T
        Epav=Epav+Epot
        Ekav=Ekav+Ekin

        if nstep > nadd: # We accumulate for nadd steps, and update then?
            Edum=Edum+Epot+Ekin
            Eav =Edum/float(nstep-nadd)
        else:
            Eav=Epot+Ekin
        Eerror=Eav-Epot-Ekin

        if Epot == 0:
            raise Exception("Error 1")
        
        if abs(Eerror) > .1:
            raise Exception('Error 2')

        # Handles Errors 1, 2
        # Handles logging average metrics etc...

        # Does 
        # vel = vel + accel * dt
        # x = x + vel * dt
        leapfrog(nuc,grad,mass,tstep,xyz,velo,Ekin)

        # calc E and forces?
        egrad(False,nuc,xyz,iat,mchrg,spin,etemp,Epot,grad,achrg,aspin,ECP,gradfail)

        
```

```py
# Get molecule temperature from kinetic energy of nuclei
def ekinet(nuc, velo, mass, Ekin, Temp):
    velo = torch.randn(3, nuc) # xyz coords per atom
    mass = torch.rand(nuc) # positive mass per nucleus
    Ekin = velo.pow(2).sum(1).mul(mass).sum() #

    return Ekin/2, (Ekin / (nuc * 3 * k_boltzmann)) # This is returned

# estimate the electronic temp in Fermi smearing for given IEE and ax
def setetemp(nfrag, eimp, etemp):
    etemp = 5000. + 20_000. * ax # The fuck?
    if eimp > 0 and nfrag <= 1: # If eimp is non neg, and one frag only
        # increase electron temperature, by 
        etemp = etemp + max(eimp, 0) * ieetemp # What
    return etemp

# get energy, gradient, charge and spin density on atoms from QC
def egrad(
    first: bool, 
    
    nuc: int, 
    xyz, # fp64 ndarray[3, nuc], 
    iat, # int32 ndarray[nuc]
    mchrg, # int
    spin, # int
    etemp, # fp64 scalar, electron temp/energy?
    
    # E, grad, 
    E, # fp64 mol energy?
    grad, # fp64 [3, num nucl] (gradient of what?)
    qat, # fp64, [nuc] Reads as Q at [i] atomic charge (q-at), 
    aspin, # fp64, [nuc]

    ECP, # bool (what?)
    gradfail, #  Error code (for gradient explosion?)
    ):

    disp = 0 # scalar
    qat.zero_() # inplace zero
    E = 0 # scalar
    grad.zero_()
    aspin.zero_()

    gradfail = False
    # Init all 
    # TODO

# Verlet leapfrog algorithm
def leapfrog(nuc, grad, amass, tstp, xyz, vel, ke):
    #   integer  :: nat,nstp
    #   integer  :: j,k

    #   real(wp) :: grad(3,nat), amass(nat)
    #   real(wp) :: xyz (3,nat), vel(3,nat)
    #   real(wp) :: tstp,ke
    #   real(wp) :: velold, velavg,mass

    ke = .0
    # this is v_t-1/2
    vel_old = vel.clone()
    acc = grad / mass # [3, nuc]

    # v_t+1/2  <- (v_t-1/2) + acc * deltaT
    vel = vel - acc * tstp  # acc [3, nuc], mass is scalar, tstp is scalar
    
    # (avg of v_t+1/2 and v_t-1/2)
    vel_avg = .5 * (vel_old + vel).sum() # scalar, 

    # x_t+1 <- x_t-1 + delta_t * v_t+1/2
    xyz += tstp * vel # move all molecules [3, nuc] -> [3, nuc]

    ke = .5 * (mass * vel_avg ** 2).sum() # kin energy? scalar, non-neg


    # for i in range(nuc):
    #     mass = amass[k]
    #     for d in range(3):


    #   ke = 0.0_wp
    #   do k = 1,nat
    #      mass = amass(k)
    #      do j=1,3
    #         velold   = vel(j,k)
    #         vel(j,k) = vel(j,k) - (tstp * grad(j,k) / mass)
    #         velavg   = 0.5_wp * (velold + vel(j,k))
    #         xyz(j,k) = xyz(j,k) + (tstp * vel(j,k))
    #         ke       = ke + 0.5_wp * (mass * velavg * velavg)
    #      enddo
    #   enddo
```