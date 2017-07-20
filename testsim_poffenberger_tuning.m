function poffenberger
% contralateral tuning for space and effector vs crossed vs uncrossed

% example of same tuning for space and effector, pos. CUD
% % RH
% % left hand
% LL = 0.95;
% LR = 0.7;
% 
% % right hand
% RL = 0.7;
% RR = 0.2;
% end of example

% RH
% left hand
LL = 0.95;
LR = 0.7;

% right hand
RL = 0.5;
RR = 0.2;

% space
si(LL,LR)
si(RL,RR)
mean([si(LL,LR) si(RL,RR)])

% effector
si(LL,RL)
si(LR,RR)
mean([si(LL,RL) si(LR,RR)])

CU = si((LR+RL),(LL+RR))


range = 0.2:0.25:1; % response amplitude range

for i1 = 1:length(range)
	for i2 = 1:length(range)
		for i3 = 1:length(range)
			for i4 = 1:length(range)
				LL = range(i1);
				LR = range(i2);
				RL = range(i3);
				RR = range(i4);
				
				space_sel_l_hand(i1,i2,i3,i4) = si(LL,LR);
				space_sel_r_hand(i1,i2,i3,i4) = si(RL,RR);
				effec_sel_l_spac(i1,i2,i3,i4) = si(LL,RL);
				effec_sel_r_spac(i1,i2,i3,i4) = si(LR,RR);
				
				ll(i1,i2,i3,i4) = LL;
				lr(i1,i2,i3,i4) = LR;
				rl(i1,i2,i3,i4) = RL;
				rr(i1,i2,i3,i4) = RR;
				
				
				CU(i1,i2,i3,i4) = si((LR+RL),(LL+RR));
			end
		end
	end
end



CU_r = reshape(CU,length(range)^4,1);
space_sel_l_hand_r = reshape(space_sel_l_hand,length(range)^4,1);
space_sel_r_hand_r = reshape(space_sel_r_hand,length(range)^4,1);
effec_sel_l_spac_r = reshape(effec_sel_l_spac,length(range)^4,1);
effec_sel_r_spac_r = reshape(effec_sel_r_spac,length(range)^4,1);

ll_r = reshape(ll,length(range)^4,1);
lr_r = reshape(lr,length(range)^4,1);
rl_r = reshape(rl,length(range)^4,1);
rr_r = reshape(rr,length(range)^4,1);


[~,idx] = unique([space_sel_l_hand_r space_sel_r_hand_r effec_sel_l_spac_r effec_sel_r_spac_r CU_r],'rows');


CU_ = CU_r(idx);
space_sel_l_hand_ = space_sel_l_hand_r(idx);
space_sel_r_hand_ = space_sel_r_hand_r(idx);
effec_sel_l_spac_ = effec_sel_l_spac_r(idx);
effec_sel_r_spac_ = effec_sel_r_spac_r(idx);

ll_r_ = ll_r(idx);
lr_r_ = lr_r(idx);
rl_r_ = rl_r(idx);
rr_r_ = rr_r(idx);

[~,isor] = sort(CU_);

figure(1)

plot(CU_(isor),'m.-'); hold on;
plot(space_sel_l_hand_(isor),'bo:'); hold on;
plot(space_sel_r_hand_(isor),'go:'); hold on;
plot(effec_sel_l_spac_(isor),'bd-'); hold on;
plot(effec_sel_r_spac_(isor),'gd-'); hold on;
plot((space_sel_l_hand_(isor) + space_sel_r_hand_(isor))/2,'r-'); hold on;
plot((effec_sel_l_spac_(isor) + effec_sel_r_spac_(isor))/2,'c-'); hold on;


add_zero_lines(1,0);
legend({'CUD','space sel l hand','space sel r hand','hand sel l space','hand sel r space','space sel','hand sel'});
title('RH');

figure(2)
scatter((space_sel_l_hand_(isor) + space_sel_r_hand_(isor))/2,(effec_sel_l_spac_(isor) + effec_sel_r_spac_(isor))/2,100*(abs(min(CU_(isor)))+0.01+CU_(isor)),CU_(isor));
colormap(jet(length(isor)));
xlabel('space sel');
ylabel('hand sel');
title('CUD as function of space and hand selectivity');
save lll

function CU = cu(LL,LR,RL,RR)
% crossed-uncrossed
CU = (LR + RL) - (LL + RR);


function SI = si(C,I)
% selectivity index, contra- vs ipsi-
SI = (C-I)/(C+I);






