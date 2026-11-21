param([string]$In, [string]$Out)
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System; using System.IO; using System.Drawing; using System.Drawing.Imaging;
public static class Dds {
  static void C565(int c, out int r, out int g, out int b){ r=((c>>11)&31)*255/31; g=((c>>5)&63)*255/63; b=(c&31)*255/31; }
  public static void Convert(string inp, string outp){
    byte[] d = File.ReadAllBytes(inp);
    int h = BitConverter.ToInt32(d,12), w = BitConverter.ToInt32(d,16);
    string fc = System.Text.Encoding.ASCII.GetString(d,84,4);
    bool dxt5 = fc=="DXT5", dxt1 = fc=="DXT1"; if(!dxt1 && !dxt5) throw new Exception("unsupported "+fc);
    int off = 128; Bitmap bmp = new Bitmap(w,h,PixelFormat.Format32bppArgb);
    for(int by=0; by<(h+3)/4; by++) for(int bx=0; bx<(w+3)/4; bx++){
      int[] alpha = new int[16]; for(int i=0;i<16;i++) alpha[i]=255;
      if(dxt5){ int a0=d[off], a1=d[off+1]; int[] av=new int[8]; av[0]=a0; av[1]=a1;
        if(a0>a1){ for(int i=1;i<7;i++) av[i+1]=((7-i)*a0+i*a1)/7; } else { for(int i=1;i<5;i++) av[i+1]=((5-i)*a0+i*a1)/5; av[6]=0; av[7]=255; }
        ulong bits=0; for(int i=0;i<6;i++) bits|=((ulong)d[off+2+i])<<(8*i);
        for(int i=0;i<16;i++) alpha[i]=av[(int)((bits>>(3*i))&7)]; off+=8; }
      int c0=BitConverter.ToUInt16(d,off), c1=BitConverter.ToUInt16(d,off+2); uint idx=BitConverter.ToUInt32(d,off+4); off+=8;
      int[,] col=new int[4,4]; int r0,g0,b0,r1,g1,b1; C565(c0,out r0,out g0,out b0); C565(c1,out r1,out g1,out b1);
      col[0,0]=r0;col[0,1]=g0;col[0,2]=b0;col[0,3]=255; col[1,0]=r1;col[1,1]=g1;col[1,2]=b1;col[1,3]=255;
      if(c0>c1 || dxt5){ col[2,0]=(2*r0+r1)/3;col[2,1]=(2*g0+g1)/3;col[2,2]=(2*b0+b1)/3;col[2,3]=255; col[3,0]=(r0+2*r1)/3;col[3,1]=(g0+2*g1)/3;col[3,2]=(b0+2*b1)/3;col[3,3]=255; }
      else { col[2,0]=(r0+r1)/2;col[2,1]=(g0+g1)/2;col[2,2]=(b0+b1)/2;col[2,3]=255; col[3,0]=0;col[3,1]=0;col[3,2]=0;col[3,3]=0; }
      for(int i=0;i<16;i++){ int x=bx*4+(i%4), y=by*4+(i/4); if(x>=w||y>=h) continue; int k=(int)((idx>>(2*i))&3);
        int a = dxt5 ? alpha[i] : col[k,3]; bmp.SetPixel(x,y,Color.FromArgb(a,col[k,0],col[k,1],col[k,2])); }
    }
    bmp.Save(outp, ImageFormat.Png);
  }
}
"@
[Dds]::Convert($In, $Out)
