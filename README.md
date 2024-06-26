# Prep2Cry: a set of scripts to prepare CRYSTAL input files en masse (and other helpers) – version 2!
## What it contains?
* client-side script **prep2cry.sh** to extract data from a CIF file
* server-side scripts and templates:
    * **pre2crys**                -- create the input file
    * **cryalot**                 -- create a batch of input files with certain funcional and basis set combinations
    * **cry1**                    -- prepare files `machines.LINUX` and `nodes.par` for a launch on a single node
    * **fxnl2cry.sh**             -- make the functional definition into a parameter to `pre2crys`
    * **gui2cry.sh**              -- get the element list and group from .GUI file if EXTERNAL geometry is used in `pre2crys`
    * **gpa2hb3.py**              -- converts pressure between GPa and atomic units (hartrees per cubic bohr)
    * auxillary file **.pertanu** -- a list of all elements, with the line number being the element number
    * an **example directory** of basis sets
    * an **example directory** of "custom" density functionals
    * a **required directory** of templates for calculations

## Changes since version 1
The update was quite significant:
* introduced support for all 7 crystal systems, not just the cubic one;
* introduced support for molecules, currently C<sub>1</sub> symmetry only;
* introduced support for other calculation types than geometry optimization;
* introduced specifications for multiple parameters and the density grid.

Changes on practical level:
* a new directory `tmpls` with templates;
* accordingly, the default values for the environmental variable `CRYVAR_TMPLDIR` has changed;
* many new and REQUIRED options when running `pre2crys`;
* no prompt for template when running `cryalot`;
* `cryalot` now prompts for several more things;
* but these prompts can be escaped if You use command-line arguments for `cryalot`.

## Where to place the scripts and the directories
The scripts shold be in `$HOME/bin` or in any other directory You added to Your `$PATH`. prep2cry.sh should be on the machine You are viewing the CIF files (hereinafter called the 'client' or 'local machine'); all the other scripts must be on the machine You are using for calculations (hereinafter called the 'server').

Also, do not forget to place `.pertanu` under Your `$HOME` -- BOTH on the 'client' and the 'server'.

The directories (and template files) under prep2cry.serv.dirs must also be present on the 'server', and their locations must also be mentioned in the environmental variables (see below).

You can [download all the main branch as an archive](https://github.com/esmuigors2/Prep2Cry/archive/master.tar.gz) and upload in on the 'server', extract all the contants and place them in appropriate folders.

## Environmental variables
The scripts intended to run on the 'server' rely on three environmental variables:
  1. `CRYVAR_TMPLDIR`  -- the directory containing template files, such as tmpl_opt.d12 (if empty, defaults to `$HOME/crydarba/tmpl/tmpls`)
  2. `CRYVAR_BSDIR` -- the directory containing the directories with basis sets (if empty, defaults to `$HOME/crydarba/tmpl/basis`)
  3. `CRYVAR_FXLDIR` -- the directory containing the custom functionals, defined as they would be in the input file (if empty, defaults to `$HOME/crydarba/tmpl/fxnls`)

You can add to Your $HOME/.bashrc or $HOME/.bash_profile the following (adjust directory paths to Your situation, i.e., where did You extract those files to):

     CRYVAR_TMPLDIR="$HOME/cryda/tmpl/tmpls"
     CRYVAR_BSDIR="$HOME/cryda/tmpl/basis"
     CRYVAR_FXLDIR="$HOME/cryda/tmpl/fxnls"
     export CRYVAR_FXLDIR CRYVAR_BSDIR CRYVAR_TMPLDIR

## Usual workflow
### 1. Structure preparation
(If You don't have a .GUI file from a previous run of CRYSTAL which would be used, ) **on the machine containing the CIF/XYZ file** launch:
   
        prep2cry.sh CIFNAME.cif      # or:  prep2cry.sh XYZNAME.xyz
   
This will return the first part of the pre2crys command, containing:
- -g : space group (number according to ITC) – for molecules, only C<sub>1</sub> is currently supported
- -l : for CIF files – lattice constant OR constants separated with number sighns (#); e.g., "a#b#c#α#β#γ" as a general example for triclinic structure, or "8.5732#12.9668#7.2227#90.658#115.917#87.626" for <a href="http://www.crystallography.net/cod/1529639.cif">microcline</a>
- -n : number of elements in the compound
- -w : Wyckoff positions of the elements within the cell (fractional XYZ coordinates) – for CIF files; XYZ coordinates of atoms within the molecule – for XYZ files
      
Like this:

      pre2crys -g 225 -l 5.463209 -n 2 -w "20 0 0 0#9 0.25 0.25 0.25#"
      
The Wyckoff positions are given in a single line where the hash substitutes for the newline. Otherwise they are just as in the input file.

**Attention!** If the input is longer than 4096 symbols, You will have to modify it later, specifically regarding Wykoff positions

**Site-specific basis sets**

**If** You want to define specific basis set for a site position, please prefix the corresponding atom number with 1, 10, 100, …

**If** You want to define a specific ECP for a site position, please prefix the corresponding atom number with 2, 3, 4, …

### 2. Go to cluster
Then log in onto Your computational server and make a directory for calculation of Your compound of interest.
### 3. Select the way of preparation
Then continue with **either** 4. or 5. If You have no idea, [choose 5](#5-high-level-way).
### 4. Low-level way
If You only want to prepare a single file AND You are comfortable with using bash scripts:
   * copy the output of `prep2cry.sh` (as shown before) or `gui2cry.sh` (use and results are the same, except that the results won't have the lattice constants) _and add the parts in bold_:
     
     <pre>pre2crys -g 225 -l 5.463209 -n 2 -w "20 0 0 0#9 0.25 0.25 0.25#" <b>-s c -a f -f 0 -px -g XXLGRID -d PBE0 -b pob_tzvp_2012 CaF2_tzvp2018_PBE0_opt.d12</b></pre>
     
     Here,
     - -d option gives the DFA (density functional approximation) used;

       If the argument for this option is HF, RHF or UHF, the script will automatically remove the DFT block from the input file.
     
     - -b specifies the basis set, as found under `$CRYVAR_BSDIR/basis/Ca/pob_tzvp_2012.bas` and `$CRYVAR_BSDIR/basis/F/pob_tzvp_2012.bas` .
          
       If there is no such basis set under `$CRYVAR_BSDIR/basis/$element_name` , the script will abort, and the input file will not be prepared. Please do one of the following:
       
       * use `cryalot` (see step 5);
       * find the missing basis set and repeat the run of pre2crys;
       * make a symbolic link, named after the basis set missing, which points to some basis set actually present for the element in question
       
     - **-s** specifies the type of input geometry:
         - c means a crystal;
         - m means a molecule (NOT IMPLEMENTED YET);
         - e means that the geometry will be obtained from a NAME.gui or fort.34 file **which must be manually placed in the directory prepared by the script**.
       
     - **-x** specifies, for a rhombohedric lattice, cell of which crystal system will be used in the calculation (the default is hexagonal):
         - r means to use the non-default rhombohedral cell;
         - h means to use the default hexagonal cell.
       
     - **-a** specifies the action, a calculation to perform:
         - s means just an energy calculation (single point);
         - o means a geometry optimization;
         - f means a calculation of phonon frequencies;
         - e means a calculation of elastic constants.
       
     - **-f** (_use is optional even with -a f_) specifies options for the frequency/phonon calculations:
         - i means we need to calculate IR (infrared) intensities as well
         - r means we need to calculate Raman intensities as well;
         - d means we need to calculate phonon dispersion as well (NOT IMPLEMENTED YET);
         - e means we need to calculate phonon density of states as well (NOT IMPLEMENTED YET);
         - 0 means no additional calculations will be run except for frequency modes (**REQUIRED IF NO OTHER OPTION IS SELECTED**).
           
     - **-r** option gives the density grid used;
           
     - **-p** option requests a Mulliken population analysis to be run after the wave function is calculated;
           
     - **-P** option requests a calculation under hydrostatic pressure; You should provide it in GPa after this option;

       The script will automatically convert GPa to atomic units if needed, using precisely as many significant digits as in the input.
       
       Pressures below atmospheric are not supported, though (what a coincidence regarding Python).
       
     - `CaF2_tzvp2018_PBE0_opt.d12` is the name of input file You want to produce.
     - If the input line is longer than 4096 characters, You will need to paste all the Wykoff coordinates into a file /tmp/pre2crys.ext and replace them in the command with the word "ext".

       Like this:

           pre2crys -g 1 -n 199 -w ext
   * press `Enter` to launch this command
   * The script will ask for the comment to be put into the first line of the new input file. Please put something meaningful in here, to be able later to understand what in the world did You calcualte.
   
     If left empty, it will produce the following:
     
         FILENAME TEMPLATE_NAME FUNCTIONAL_NAME BASIS_SET_NAME BASIS_SETS_FOR_INDIVIDUAL_ELEMENTS_IF_DIFFERENT_FROM_BASIS_SET_NAME
     
   * For custom functionals, You should get the argument for the -d option by launching
     
         fxnl2cry.sh PW1PW20hf
     
     which will search for the definition of that density functional inside the file `$CRYVAR_FXLDIR/PW1PW20hf.fxl` .
### 5. High-level way
👉 If You want to prepare a lot of input files, using all combinations of some density functionals and basis sets;

👉 OR if You are not too comfortable with command line:
   * launch the following command:
     
            cryalot
    
   * it will prompt You for:
       1. The compound name (to use in the filenames and cooment lines in input files);
       2. The type of geometry used in this calculation (crystal or molecule)
       2. Source of geometry used in calculation (CIF file, see below, or a geometry from an external file NAME.gui or fort.34 **which must be manually placed in the directory prepared by the script**);
       3. The type of calculation You want (single-point energy, geometry optimization, frequency calculation, elastic constant calculation, etc.);
       4. If the type selected was "frequency", then additional prompt is for frequency calculation options (IR or Raman intensities, etc.) – You can just press `Enter` for none;
       4. If the type selected was "geometry optimization" or "elastic constants", then additional prompt is for pressure in GPa to be applied during the calculations – You can just press `Enter` for none;
     
          The pressure will be converted from GPa to atomic units if needed, using precisely as many significant digits as in the input.
       5. Whether Mulliken population analysis will be run in the end of calculation;
       6. Which density grid should be used (if You just press `Enter`, XLGRID will be used);
       7. The list of all functionals You want to use, separated by space; e.g.,
     
               PBE0 B3LYP PW1PW20hf
          
          In this example, PBE0 and B3LYP are standard functionals (having a keyword in CRYSTAL).
          
          But `PW1PW20hf` is a custom-defined functional, which means it must have a file under `$CRYVAR_FXLDIR` , like `$CRYVAR_FXLDIR/PW1PW20hf.fxl` .
          
          The script cryalot will automatically distinguish between the two (if a file is found, it will use that; otherwise it will asume CRYSTAL knows this functional).
       8. The list of all basis sets You want to use, separated by space; e.g.,
          
               pob_tzvp_2012 pob_tzvp_rev2
          
          All basis sets are assumed to be custom basis sets and sought for in the `$CRYVAR_BSDIR` directory. Please see the description for the preparation of a single input file.
          
          If there is no such basis set under `$CRYVAR_BSDIR/basis/$element_name` , You will be prompted about which basis set to use instead.
          
          If You just press `Enter` at this point, the script will abort, and no further input files will be prepared.

          **Site-specific basis sets**

          **REMEMBER:** if You want to define specific basis set for a site position, You should have prefixed the corresponding atom number with 1, 10, 100, … in the Wykoff position definition.
          
          **If** You want to define a specific ECP for a site position, You should have prefixed prefix the corresponding atom number with 2, 3, 4, … in the Wykoff position definition.
          
          If this was done in the right way, now You should proceed as follows:
             1. At the prompt of list of basis sets, enter some words not actually corresponding to any basis set (e.g., "haha hihi" for two different setups of site-specific basis sets).
             2. Now You should be prompted for the basis set separately for each site.
       9. (If You are not using EXTERNAL geometry and the .GUI file is present,) paste the semi-finished line from `prep2cry.sh` or `gui2cry.sh`, e.g.
          
              pre2crys -g 225 -l 5.463209 -n 2 -w "20 0 0 0#9 0.25 0.25 0.25#"

          If the input line is longer than 4096 characters (typically with molecules or nanoparticles), You will need to paste all the Wykoff coordinates into a file /tmp/pre2crys.ext and replace them in the command with the word "ext".

          Like this:

              pre2crys -g 1 -n 199 -w ext
          
   * And so it will prepare separate folders with the corresponding input files.
   * **NOTE OF EFFICIENCY** You can use command-line arguments for `cryalot` to facilitate selection of calculation type and parameters.
       - For example, to run a frequency calculation (`-a f`) with intensities (`-f i`) on a crystal (`-s c`) with Mulliken analysis (`-p`), run:
     
                cryalot -s c -a f -f i -p

       - All options are the same as for `pre2crys` script (see above), but not all command-line options for pre2crys are supported in `cryalot`. The relevant options are shown in bold in the [description of pre2crys](#4-low-level-way).
### 6. Pre-launch
Then, if You want to only launch the dcalculation on a single node, You can use the command:

       cry1
     
   Which prepares files `machines.LINUX` and `nodes.par` for a launch on a single node (containing the `$HOSTNAME` of present node).
   
   By default it will use all the available threads/cores, but You can also specify this as an argument, e.g.
   
       cry1 20
       
   Usually there is no much gain to use more than 20 parallel processes, as it consumes too many resources for parallelization.
   
   Personally I usually launch multiple jobs on a single node if there are more than 20 cores.

   **!! IMPORTANT !!** You **will** need to edit **cry1** script to change our local cluster name (`lasc`) to anything You have at home.
### 7. Launch
Launch Your CRYSTAL job as usual (I usually save the output to a .logc file, also less problems with nohup):

       nohup runPcry23 20 INPUT_FILE_NAME &> INPUT_FILE_NAME.logc &

### 8. Enjoy!

End and glory to God.
