X=rand([100,1]);
Y=rand([100,1]);

figure('color','w');

props={'color','r','linewidth',1};
%errorbarhandle=shadedErrorBar(1:100,X,Y,props,1); %% STERR!!!!

errorbarhandle=shadedErrorBar(1:100,X,Y,props,1); %% STERR!!!!
export_fig('test', '-pdf','-transparent')
export_fig('test2', '-pdf')