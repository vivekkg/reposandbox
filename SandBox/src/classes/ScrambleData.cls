/* version: 1.0
   class : for Scramble Data
   
 */
public class ScrambleData{
    
    /* method for Scramble Text */
    Public static String scrambleText(String Value){
        String strOutput = '';
        if(String.isNotblank(value) ){
            List <String> charArray = value.split('');
            charArray.sort();
            for(String ch:charArray){
                strOutput += ch;
            }
        }
        return strOutput;
    }
    
}