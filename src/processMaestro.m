%process behavior day by day

exps = input('Input experiment set: ','s');
path = 'C:\Users\scb47\Documents\MATLAB\Diogenes\';

cd([path,exps,'dt'])
trialdataT = trialdata_reader_table('1'); 
cd([path,exps,'dt'])
writetable(trialdataT, 'trialdataT.csv')
cd ..

cd([path,exps,'rf'])
trialdataT = trialdata_reader_table('1');
cd([path,exps,'rf'])
writetable(trialdataT, 'trialdataT.csv')
cd ..

cd([path,exps,'st'])
trialdataT = trialdata_reader_table('1');
cd([path,exps,'st'])
writetable(trialdataT, 'trialdataT.csv')
cd ..

cd([path,exps])
trialdataT = trialdata_reader_table('1');
cd([path,exps])
writetable(trialdataT, 'trialdataT.csv')
c
