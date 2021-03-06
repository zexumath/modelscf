# test construction of the Hamiltonian
# in this example, we have 16 unit cells, each containing 2 atoms
# there are 2 electrons per atom (Natoms=2, it is now the num of atoms per unit cell)
# use n_extra to compute enough eigenvalues for finite temp

include("../src/Atoms.jl")
include("../src/scfOptions.jl")
include("../src/anderson_mix.jl")
include("../src/kerker_mix.jl")
include("../src/Ham_k.jl")
include("../src/hartree_pot_bc.jl")
include("../src/pseudocharge.jl")
include("../src/getocc.jl")


dx = 1.0;
Nunit = 16;
Lat = 20;
# using the default values in Lin's code
YukawaK = 0.0100
#n_extra = 10; # QUESTION: I don't know where this comes from
n_extra = 2;
epsil0 = 10.0;
T_elec = 100.0;

kb = 3.1668e-6;
au2K = 315774.67;
Tbeta = au2K / T_elec;

betamix = 0.5;
mixdim = 10;

Ndist  = 1;   # Temporary variable
#Natoms = round(Integer, Nunit / Ndist); # number of atoms
#Natoms = 1  
Natoms = 2 #(Yu) 2 atoms in each unit cell

R = zeros(Natoms, 1); # this is defined as an 2D array
for j = 1:Natoms
  R[j] = (j-0.5)*(Lat/Natoms)*Ndist+dx; #(Yu) should initialize in the first unit cell
end

sigma  = ones(Natoms,1)*(2.0);  # insulator
omega  = ones(Natoms,1)*0.03;
Eqdist = ones(Natoms,1)*10.0;
mass   = ones(Natoms,1)*42000.0;
nocc   = ones(Natoms,1)*2;          # number of electrons per atom
Z      = nocc;

# creating an atom structure
atoms = Atoms(Natoms, R, sigma,  omega,  Eqdist, mass, Z, nocc);

# allocating a Hamiltonian
ham = Ham_k(Lat, Nunit, n_extra, dx, atoms,YukawaK, epsil0, Tbeta)

# total number of occupied orbitals
Nocc = round(Integer, sum(atoms.nocc) / ham.nspin);

# initialize the potentials within the Hemiltonian, setting H[\rho_0]
init_pot!(ham, Nocc)

# we use the anderson mixing of the potential
mixOpts = andersonMixOptions(ham.Ns, betamix, mixdim )

# we use the default options
eigOpts = eigOptions();

scfOpts = scfOptions(eigOpts, mixOpts)

# running the scf iteration
@time VtoterrHist = scf!(ham, scfOpts);
length(VtoterrHist)
