# Prep2Cry: a set of scripts to prepare CRYSTAL input files en masse (and other helpers)
## What it contains?
* client-side script prep2cry.sh to extract data from a CIF file
* server-side scripts and templates:
    * pre2crys                -- create the input file
    * cryalot                 -- create a batch of input files with certain funcional and basis set combinations
    * cry1                    -- prepare files machines.LINUX and nodes.par for a launch on a single node
    * fxnl2cry.sh             -- make the functional definition into a parameter to pre2crys
    * auxillary file .pertanu -- a list of all elements, with the line number being the element number
    * an example directory of basis sets
    * an example directory of "custom" density functionals

## Where to place the scripts
The scripts shold be in $HOME/bin or in any other directory You added to Your $PATH.
Also, do not forget to place .pertanu under Your $HOME -- BOTH on the local machine and on the server.

## Environmental variables
The scripts rely on three environmental variables:
  1. CRYVAR_TMPLDIR  -- the directory containing the template file tmpl.d12 (if empty, defaults to $HOME/crydarba/tmpl)
  2. CRYVAR_BSDIR -- the directory containing the directories with basis sets (if empty, defaults to $HOME/crydarba/tmpl/basis)
  3. CRYVAR_FXLDIR -- the directory containing the custom functionals, defined as they would be in the input file (if empty, defaults to $HOME/crydarba/tmpl/fxnls)

## Usual workflow
1. On the machine containing the CIF file launch:
   
        prep2cry.sh CIFNAME.cif
   
This will return the first part of the pre2crys command, containing:
      - -g : space group (number according to ITC)
      - -l : lattice constant (currently only cubic structures are supported but the extension seems straightforward)
      - -n : number of elements in the compound
      - -w : Wyckoff positions of the elements within the cell (fractional XYZ coordinates)
      
Like this:

      pre2crys -g 225 -l 5.463209 -n 2 -w "20 0 0 0#9 0.25 0.25 0.25#"
      
The Wyckoff positions are given in a single line where the hash substitutes for the newline.

2. Then log in onto Your computational server and make a directory for calculation of Your compound of interest.
3. If You only want to prepare a single file:
   * copy the output of prep2cry.sh (as shown before) and add the parts in bold:
     
           pre2crys -g 225 -l 5.463209 -n 2 -w "20 0 0 0#9 0.25 0.25 0.25#" * -d PBE0 -b pob_tzvp_2012 CaF2_tzvp2018_PBE0_opt.d12*
     
   Here,
       - -d option gives the DFA (density functional approximation) used, while
       - -b specifies the basis set, as found under $CRYVAR_BSDIR/basis/Ca/pob_tzvp_2012.bas and $CRYVAR_BSDIR/basis/F/pob_tzvp_2012.bas .
       - CaF2_tzvp2018_PBE0_opt.d12 is the name of input file You want to produce
   * press `Enter` to launch this command
   * The script will ask for the comment to be put into the first line of the new input file. Please put something meaningful in here, to be able later to understand what in the world did You calcualte.
   * If left empty, it will produce the following:
     
         FILENAME FUNCTIONAL_NAME BASIS_SET_NAME
     
   * For custom functionals, You should get the argument for the -d option by launching
     
         fxnl2cry.sh PW1PW20hf
     
     which will search for the definition of that funcionla inside $CRYVAR_FXLDIR/PW1PW20hf .
5. If You want to prepare a lot of input files, using all combinations of some density functionals and basis sets:
   * launch the following command:
     
            cryalot
    
   * it will prompt You for:
       1. The compound name (to use in the filenames and cooment lines in input files)
       2. The list of all functionals You want to use, separated by space; e.g.,
     
               PBE0 B3LYP PW1PW20hf
          
          In this example, PBE0 and B3LYP are standard functionals (having a keyword in CRYSTAL)
          But PW1PW20hf is a custom-defined functional, which means it must have a file under $CRYVAR_FXLDIR , like $CRYVAR_FXLDIR/PW1PW20hf.fxl
          The script cryalot will automatically distinguish between the two (if a file is found, it will use that; otherwise it will asume CRYSTAL knows this functional).
       4. The list of all basis sets You want to use, separated by space; e.g.,
          
               pob_tzvp_2012 pob_tzvp_rev2
          
          All basis sets are assumed to be custom basis sets and sought for in the $CRYVAR_BSDIR directory. Please see the description for the preparation of a single input file.
          If there is no such basis set under $CRYVAR_BSDIR/basis/$element_name , You will be prompted about which basis set to use instead.
          If You just press `Enter` at this point, the script will abort, and no further input files will be prepared.
       6. The semi-finished line from prep2cry.sh, e.g.
          
              pre2crys -g 225 -l 5.463209 -n 2 -w "20 0 0 0#9 0.25 0.25 0.25#"
          
   * And so it will prepare separate folders with the corresponding input files.
6. Then, if You want to only launch the dcalculation on a single node, You can use the command:

       cry1
     
   Which prepares files machines.LINUX and nodes.par for a launch on a single node (containing the $HOSTNAME of present node
   By default it will use all the available threads/cores, but You can also specify this as an argument, e.g.
   
       cry1 20
       
   Usually there is no much gain to use more than 20 parallel processes, as it consumes too many resources for parallelization.
   Personally I usually launch multiple jobs on a single node if there are more than 20 cores.
7. Launch Your CRYSTAL job as usual:

       nohup runPcry23 20 INPUT_FILE_NAME &

8. Enjoy!

End and glory to God.
