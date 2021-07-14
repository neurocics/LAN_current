function S = lan_rectified(S ,lf,fs,n)

Rec = abs(real(S));
%Rec = SS.*conj(SS);

[b,a] = butter(n,lf/(fs/2));
S = filtfilt(b,a,double(Rec));

end