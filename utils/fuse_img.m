function imgtemp = fuse_img(img1, img2)
mask = edge(img2);
mask(mask>0.5) = 1; 
%map1 = colormap('gray');
%imgtemp = ind2rgb(gray2ind(img1/max(img1(:)), 256), map1);    
%imgtemp1 = imgtemp(:,:,2);
%imgtemp1(mask) = 1;
imgtemp1 = img1(:,:,2);
imgtemp1(mask) = 1;

%imgtemp(:,:,2) = imgtemp1;
%imgtemp1 = imgtemp(:,:,1);
%imgtemp1(mask) = 0;
img1(:,:,2) = imgtemp1;
imgtemp1 = imgtemp1(:,:,1);
imgtemp1(mask) = 0;
img1(:,:,1) = imgtemp1;
imgtemp1 = img1(:,:,3);
imgtemp1(mask) = 0;
img1(:,:,3) = imgtemp1;
imgtemp = img1;
%imgtemp(:,:,1) = imgtemp1;
%imgtemp1 = imgtemp(:,:,3);
%imgtemp1(mask) = 0;
%imgtemp(:,:,3) = imgtemp1;
return;