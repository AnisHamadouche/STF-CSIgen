addpath './examples'
addpath './src'
addpath './data'

load_and_plot_sample('D1_csi.mat', 'train');
sc = getScenarioName('UMi+NLoS');