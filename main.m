% a=0.5; t1=8; t2=8; t3=7.6;
% min=1000000;
% Ans=[];
% for i=5:0.5:10 %多起点进行最小值搜索
%     for j=1:1:20
%         [i,j]
%         [x,out]=fminsearch('func1',[i,j,i-1]);
%         if out<min
%             real=[x,out];
%             min=out;
%         end
%         if out-0.1016 < 0.05
%             Ans=[Ans; x,out]
%         end
%     end
% end

%[x,out]=fminsearch('func1',[8,7.01]);
[Time, Angle, Tm]=func(0.5,8,7.0131);
% for i=1:15
%     [Time, Angle, Tm]=func(0.5,Ans(i,1),Ans(i,2));
%     
% end