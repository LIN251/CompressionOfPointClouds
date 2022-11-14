N=5
out=zeros(10,3);
for k=1:10
    A=rand(N,3);
    [~,idx]=max(A(:,2));
    out(k,:)=A(idx,:);
end