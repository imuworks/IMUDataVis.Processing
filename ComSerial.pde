/**
 * IMU Data Visualizer for Processing.org
 *     Copyright (C) 2017 James (Aaron) Crabb
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 *  For full documentation please visit 
 *  https://github.com/jacrabb/IMUDataVis.Processing
 */
 
//import java.util.*;
import processing.serial.*;
//import java.awt.datatransfer.*;

/**
 * Class for initializing a serial port and parsing incoming data.
 * The parse function is static and you are welcome to handle the
 * serial port with any other method.
 */
public static class SerialHndlr
{
  Serial port;
  
  /**
   * Delimter character used in the serial stream.    */
  private static char delimChar = ' ';

  /**
   * The escape character used in the serial stream.   */
  private static char escapeChar = '\n';
  
  /**
   * A string that represents the beginning of useable data.   */
  private static String LineBegin = "||";
  

  /**
   * Initialize the serial port and prepare for incoming data.
   *
   * @param app       the processing app - pass 'this' 
   * @param comName   the name of the com port to open
   * @param boadrate  the board rate of the incoming serial port
   */
  public SerialHndlr(PApplet app, String comName, int boadrate) 
  {
    if (port != null) {
      port.stop();
    }
    try {
      // Open port.          Serial.list()[0]   115200
      port = new Serial(app, comName, boadrate);
      port.bufferUntil(escapeChar);
    }
    catch (RuntimeException ex) {
      // Swallow error if port can't be opened, keep port closed.
      System.out.println("ERROR Opening Port");
      port = null;
    }
  }
  
  /**
   * Set the delimter character used in the serial stream. 
   * Each value should be seperated by the single char.
   * For more info see the documentation at 
   * https://github.com/jacrabb/IMUDataVis.Processing
   * 
   * @param                                                        */
  public void setEscapeChar(char c){
    escapeChar = c;
  }
  /**
   * Set the escape character used in the serial stream.
   * Usually this is a linebreak.
   * 
   * @param                                                         */
  public void setDelimChar(char c){
    delimChar = c;
  }
  /**
   * Set the string that represents the beginning of useable data.
   * Its expected that each line which contains data will being 
   * with this special string.  By default it is "||".
   * 
   * @param                                                          */
  public void setSafeLineSequence(String s){
    LineBegin = s;
  }

  /**
   * Parse the incoming serial data and add all data into the
   * appropriate place in the global data store.
   * NOTE this can be called statically, but you won't be able
   * to change the parameters.
   * 
   * @param incoming    the string that has been retrieved from
   *                    the serial port to be parsed
   * @param dataref     the global data store
   */
  public static void parse(String incoming, dataWindow dataref) {
    if(dataref == null)
      return; // because there's nothing to do if there's no data model yet
    if(incoming != null) { 
      String[] list = split(incoming, delimChar);
      if ( (list.length > 3) && (list[0].equals(LineBegin)) ) { 
        int i = 0;
        for(String s : dataref.DataPoints.keySet()) { // TODO: whoa, don't make datapoints public
          if(list.length < i+3)
            return;
          if(s != "ignore" && s != "null") // TODO: ignore not implemented properly
            dataref.addPoint(s, float(list[++i]), float(list[++i]), float(list[++i]));
          else
            i = i+3;
        }
      }else{ System.out.print(incoming); } // show general messages in the console
    }
  }
}


/*
        //dataref.addPoint("orientation",   float(list[1]), float(list[2]), float(list[3]));
        dataref.addPoint("complimentary", float(list[4]), float(list[5]), float(list[6]));
        dataref.addPoint("gyroorient",    float(list[7]), float(list[8]), float(list[9]));
        //dataref.addPoint(gyro,          float(list[10]), float(list[11]), float(list[12]));
        dataref.addPoint("accelnograv",   float(list[13]), float(list[14]), float(list[15]));
        dataref.addPoint("accel",         float(list[16]), float(list[17]), float(list[18]));
        System.out.println(s + ++i + ++i + ++i);
        */