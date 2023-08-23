package forever;

#if macro
import haxe.macro.Expr;
#end

class Utils
{
    /**
     * Replaces the code to like not set if the value is null
     * if an error appears here, then the error is where its called, not in here, since it replaces the code
    **/
    public static macro function safeSet(setTo:Expr, value:Expr) {
        return macro if(${value} != null) ${setTo} = ${value};
    }
}