# Introduction to FPGA Programming <br/> _Using Xilinx Vivado and VHDL_

## PhD Degree in Physics, University of Torino

Git repository for the _Introduction to FPGA Programming Using Xilinx Vivado and VHDL_
PhD course at University of Torino, Physics Department.


# Contents

* [**Git configuration**](#git-configuration)
* [**Repository download**](#repository-download)
* [**Create your personal development branch**](#create-your-personal-development-branch)
* [**UNIX environment setup**](#environment-setup)
* [**Sample Xilinx Vivado simulation flow**](#sample-xilinx-vivado-simulation-flow)
* [**Basic git commands**](#basic-git-commands)
* [**Webex lectures**](#webex-lectures)


# Git configuration
[**[Contents]**](#contents)

### Linux installation

In case `git` is not installed on your machine, use

```
% sudo yum install git
```

or

```
% sudo apt-get install git
```


### Windows installation

For Windows users, download and install **Git for Windows** from the project official page : 

```
https://gitforwindows.org
```


### Initial configuration

The first time you use `git`, type:

```
% git config --global user.name "Your Name"
% git config --global user.email your.email@example.com
```

You can check your configuration at any time with:

```
% git config --list
```


# Repository download
[**[Contents]**](#contents)

Download the repository using:


```
% cd Desktop
% git clone https://github.com/lpacher/fphd.git [optional target directory]
```

By default a new `fphd/` directory containing the repository will be created where you invoked the above `git` command, unless
you specify a different target directory as optional parameter.

As an example :


```
% cd Desktop
% git clone https://github.com/lpacher/fphd.git FPGA
```


You can create a `git root` alias to easily locate the Git top-level directory:

```
% cd fphd
% git config --global alias.root "rev-parse --show-toplevel"
% git root
```

For setting up the proper command-line runtime environment, refer to section [**Environment setup**](#environment-setup).

** **WARN:** All `git` commands **must be invoked** inside the top `lae/` directory or from any other sub-directory of the repository !


# Create your personal development branch
[**[Contents]**](#contents)

By default, the first time you download the repository you are in the `master` branch.
The `master` branch should always represent the "stable version" of the project :

```
% git branch
*master
```

The asterisk indicates the **current working branch**.


As a first step after downloading the repository for the first time
**create your personal development branch** named `student` :

```
% git branch student
% git checkout student
```

You can now **list all branches** in your local machine with :

```
% git branch
master
*student
```

Please, be sure that the asterisk now points to your own development branch `student` and not to the `master` branch.


# Environment setup
[**[Contents]**](#contents)

Sample scripts `sample/bashrc` and `sample/cshrc` for Linux, as well `sample/login.bat` for Windows are provided to support 
both `csh/tcsh` and `sh/bash/zsh` Linux shells and the Windows Command Prompt and to help students to setup the proper UNIX/Windows
runtime environment.

# Sample Xilinx Vivado simulation flow
[**[Contents]**](#contents)

A small VHDL simulation example is provided to **test your environment setup** and **tools installation**.<br/>
Step-by-step instruction explaining how to run this test flow can be found [**here**](fpga/test/README.md).


# Basic git commands
[**[Contents]**](#contents)

A small collection of most frequently used `git` **command-line syntax** for your day-to-day work and common tasks can be found [**here**](doc/git/README.md).
A more complete guide to the basic `git` commands can be found [**here**](http://doc.gitlab.com/ee/gitlab-basics/start-using-git.html).



# Webex lectures
[**[Contents]**](#contents)


* Lecture 1<br/>

TODO

