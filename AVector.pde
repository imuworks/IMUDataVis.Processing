/**
 * Extension of PVector with the inclusion of a precalculated magnitude.
 * I found it silly to recalculate a vector's mag or magSquare on every Draw().
 * Possible the VM cache the float anyway, but doubt it and haven't investigated.
 *
 * NOTE do not update component values directly as mag() will not be updated.
 *
 * PVector initially based on the Vector3D class by http://www.shiffman.net Dan Shiffman
 */
public class AVector extends PVector
{
  /**
   * The calculated magnitude of the vector   */
  public float magnitude;
  
  // we WANT to make x/y/z private 
  //  or else they can be updated without calling precalcMag()
  //  But we can't, because members can't be overriden
  //  and L. Substitution doesn't allow scope contraction anyway!
  //private float x, y, z;
  
  public AVector(){
    super(); // this isn't nessisary and may even be a bad idea
  }
  public AVector(float x, float y, float z){
    super(x, y, z);
    precalcMag();
  }
  public AVector(float x, float y){
    super(x, y);
    precalcMag();
  }
  
  
  public AVector set(float x, float y, float z) {
    super.set(x, y, z);
    precalcMag();
    return this;
  }
  public AVector set(float x, float y) {
    super.set(x, y);
    precalcMag();
    return this;
  }
  public AVector set(PVector v) {
    super.set(v);
    precalcMag();
    return this;
  }
  public AVector set(float[] source) {
    super.set(source);
    precalcMag();
    return this;
  }
  
  // TODO: Does not having this cause a PVector to be returned?
  //public AVector copy(){
  //  return new AVector(x, y, z);
  //}
  
  // The getters are unnessisary because x/y/z are public
  //  But setters must be used or else break precalculation
  public float x(){ return x; }
  public float y(){ return y; }
  public float z(){ return z; }
  public void x(int val){ x = val; precalcMag(); }
  public void y(int val){ y = val; precalcMag(); }
  public void z(int val){ z = val; precalcMag(); }
  
  // added some other way to access component values, 
  //  because sometimes its not an 'x/y/z' *shrugs*
  public float i(){ return x; }
  public float j(){ return y; }
  public float k(){ return z; } 
  public void i(int val){ x = val; precalcMag(); }
  public void j(int val){ y = val; precalcMag(); }
  public void k(int val){ z = val; precalcMag(); }
  
  // TODO: need to do all the add() sub() dot() etc, but there're lots of them
  
  
  // The whole idea is to add a precalculated magnitude to PVec
  private void precalcMag() {
      magnitude = super.mag();//(float) Math.sqrt(x*x + y*y + z*z);
  }
  // Update precalculated magnitude 
  @Override
  public float mag() {
    precalcMag();
    return magnitude;
  }
  // Get precalculated mag
  public float getMag(){
    return magnitude;
  }
}


/* A few tests
  AVector test = new AVector(1,15,7);
  System.out.println(test);
  System.out.println(test.getMag());
  System.out.println(test.mag());
  System.out.println(test.getMag());
  float[] bazinga = new float[3];
  test.get(bazinga);
  System.out.print(bazinga[0] + " " + bazinga[1] + " " + bazinga[2]);
  
*/