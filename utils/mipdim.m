function img_out = mip_Dean(img_in, dim)
img_out = squeeze(max(img_in, [], dim));
return;