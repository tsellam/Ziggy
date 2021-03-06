# rocks 015 017 019 020 /  021 023 024 027

################
# SETUP SCRIPT #
################
ssh cwi
ssh rocks021
mkdir ~/R ~/R/library ~/R/sources

cd ~/R
wget --quiet http://cran.xl-mirror.nl/src/base/R-3/R-3.1.2.tar.gz
tar xzvf R-3.1.2.tar.gz
cd R-3.1.2
./configure  --with-x=no
make
echo 'export PATH=/local/sellam/R/R-3.1.2/bin:$PATH' >>  $HOME/.bashrc
source ~/.bashrc

echo 'R_LIBS_USER="~/R/library"' >  $HOME/.Renviron
echo 'install.packages("dplyr",lib="~/R/library", repos="'http://cran.us.r-project.org'")' | R --no-save
echo 'install.packages("tidyr",lib="~/R/library", repos="'http://cran.us.r-project.org'")' | R --no-save
echo 'install.packages("e1071",lib="~/R/library", repos="'http://cran.us.r-project.org'")' | R --no-save
echo 'install.packages("foreign",lib="~/R/library", repos="'http://cran.us.r-project.org'")' | R --no-save
echo 'install.packages("igraph",lib="~/R/library", repos="'http://cran.us.r-project.org'")' | R --no-save
echo 'install.packages("R.utils",lib="~/R/library", repos="'http://cran.us.r-project.org'")' | R --no-save
echo 'install.packages("class",lib="~/R/library", repos="'http://cran.us.r-project.org'")' | R --no-save
echo 'install.packages("ggplot2",lib="~/R/library", repos="'http://cran.us.r-project.org'")' | R --no-save
echo 'install.packages("clusterGeneration",lib="~/R/library", repos="'http://cran.us.r-project.org'")' | R --no-save

#################
# CHECKOUT CODE #
#################
rm -rf  /scratch/sellam
mkdir /scratch/sellam
cd /scratch/sellam
git clone https://tsellam@bitbucket.org/tsellam/mme.git

cd mme/Experiments/Baselines/Rlib
R CMD SHLIB info_theory.c
cd ../.. 

########################
# RUN WITH DOWNLOADING #
########################
cd /scratch/sellam/mme/experiments
nohup  ./wrap_experiments.sh download &
tail -f nohup.out



###################
# RUN EXPERIMENTS #
###################
# rocks  015 017 019 020 021 023 027 028

ssh cwi
ssh rocks015

killall R
cd /scratch/sellam/mme
git checkout -- .
git pull -f

cd /scratch/sellam/mme/Experiments/Baselines/Rlib
R CMD SHLIB info_theory.c
cd /scratch/sellam/mme/Experiments
rm nohup.out
nohup ./wrap_experiments.sh &
tail -f nohup.out

#R -f TestSyntheticData.R test

################
# SEND RESULTS #
################
ssh cwi
ssh rocks021
cd /scratch/sellam/mme/Experiments
tarname=FindView-`hostname -s`-` date +'%B%d'`.tar.gz
tar -czvf $tarname nohup.out *.out *.log
scp $tarname sellam@warsaw.ins.cwi.nl:~

#########################
# CHECKS IT IS ALL FINE #
#########################
# rocks  015 017 019 020 021 023 027 028
ssh cwi
ssh rocks015
cd /scratch/sellam/mme/Experiments
tail -f nohup.out


########################
# INTERRUPT AND RELOAD #
########################
killall -usellam

ssh rocks015
killall R
cd /scratch/sellam/MME
git checkout -- .
git pull -f

cd /scratch/sellam/mme/Experiments
rm nohup.out
nohup ./wrap_experiments.sh &
tail -f nohup.out




######################
# Rebuilds databases #
######################
ssh cwi
ssh rocks028
killall R

cd /scratch/sellam/MME
git checkout -- .
git pull -f

cd /scratch/sellam/mme/Data
./get_data.sh



##################
# TEST SPECIFICS #
##################
# rocks  015 017 019 020 021 023 027 028
cd /scratch/sellam/mme
git checkout -- .
git pull -f


cd /scratch/sellam/mme/Experiments/Baselines/Rlib
R CMD SHLIB info_theory.c
cd /scratch/sellam/mme/Experiments
R -f TestSyntheticData.R --args group1

