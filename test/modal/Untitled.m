ch1 = load('reg_acc_ch1.txt')';
ch2 = load('reg_acc_ch2.txt')';
ch3 = load('reg_acc_ch3.txt')';
[vch1,hch1] = size(ch1);
[vch2,hch2] = size(ch2);
[vch3,hch3] = size(ch3);

vectch1 = vch1*hch1;
vectch2 = vch2*hch2;
vectch3 = vch3*hch3;

reg_ch1 = [];
reg_ch2 = [];
reg_ch3 = [];

%reg ch1

for i = 1:vectch1
    reg_ch1(i,1) = ch1(i);
    reg_ch2(i,1) = ch2(i);
    reg_ch3(i,1) = ch3(i);
end



fileID = fopen('reg_ch1.txt','w');
fprintf(fileID,'%6.4f\r\n',reg_ch1);
fclose(fileID);
fileID = fopen('reg_ch2.txt','w');
fprintf(fileID,'%6.4f\r\n',reg_ch2);
fclose(fileID);
fileID = fopen('reg_ch3.txt','w');
fprintf(fileID,'%6.4f\r\n',reg_ch3);
fclose(fileID);