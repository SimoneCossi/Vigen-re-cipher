{- Programma Haskell che implementa il cifrario di Vigenère -}

               {- importazione delle librerie -}

{- Libreria necessaria per utilizzare:
	- toLower che converte una lettera nella corrispondente 
	  lettera minuscola -}
import Data.Char
 
{- Libreria necessaria per utilizzare i valori di tipo Maybe. 
   Un valore Maybe a, può contenere il valore di a (rappresentato come Just a) 
   oppure può essere vuoto (rappresentato come Nothing). 
   Abbiamo utilizzato la seguente funzione di questa libreria:
	- fromMaybe che accetta un predefinito e un valore Maybe. 
	  Se il valore Maybe è Nothing, restituisce il valore predefinito; 
	  in caso contrario, restituisce il valore contenuto nel Maybe. -}
import Data.Maybe

{- Libreria necessaria per utilizzare:
	-  elem che verifica se un elemento si trova nella lista 
	-  cycle che permette di rendere circolare una lista finita;
	-  lookup che cerca una chiave in un elenco di associazione e 
	   restituisce l’associazione a quella chiave;
	-  elemIndex che restituisce l’indice del primo elemento nella lista data,
	   oppure restituisce Nothing se l’elemento non compare nella lista;
	-  zipWith che restituisce una lista formata dall'unione di due liste 
      tramite la funzione data come primo argomento. -}
import Data.List

{- Libreria necessaria per utilizzare:
	-  readMaybe che ha successo solo se restituisce esattamente un valore. -}
import Text.Read


               {-   MAIN   -}

{- Programma che chiede all'utente di scegliere se cifrare o decifrare un testo 
   in base ad una chiave. 
   Fatta la scelta il programma prosegue chiedendo all'utente di inserire la 
   chiave e il testo da elaborare. 
   I dati vengono validati e in caso non siano accettabili viene chiesto 
   all'utente di reinserirli.
   Conclude comunicando all'utente il testo criptato o decriptato secondo 
   la chiave inserita -}

main :: IO()
main = do
        putStrLn "\nQuesto programma Haskell contiene al suo interno il cifrario di Vigenère"
        putStrLn "Si può scegliere di cifrare o decifrare un messaggio tramite una qualsiasi chiave."
        putStrLn "\nVengono accettate sia lettere maiuscole che minuscole, "
        putStrLn "tuttavia nella fase di cifratura o decifratura verranno tutte restituite in minuscolo."
        putStrLn "\nScrivere:  1       per cifrare una parola o un messaggio"
        putStrLn "Scrivere:  2       per decifrare una parola o un messaggio"
        putStrLn "Scrivere un qualsiasi altro numero per terminare il programma\n"

{-    if utilizzato per far scegliere all'utente se cifrare o decifrare un testo    -}
        opzione <- acquisisciInt 
        if opzione == 1  
            then do  
                    putStrLn "È stato scelto di cifrare un messaggio\n"
                    putStrLn "Scrivere la chiave tra \"\""                    
                    chiave <- acquisisciStringa
                    putStrLn "\nScrivere il testo da cifrare tra \"\""
                    testo <- acquisisciStringa
                    putStrLn "\nIl testo cifrato è:"
                    putStrLn (vigenere chiave testo)
                    putStrLn "\n"
         else if opzione == 2
            then do  
                     putStrLn "È stato scelto di decifrare un messaggio\n"
                     putStrLn "Scrivere la chiave tra \"\""
                     chiave <- acquisisciStringa
                     putStrLn "\nScrivere il testo da decifrare tra \"\""
                     testo <- acquisisciStringa
                     putStrLn "\nIl testo decifrato è:"
                     putStrLn (unvigenere chiave testo)
                     putStrLn "\n" 
         else putStrLn "\nProgramma terminato\nFate ripartire il programma se desiderate continuare\n\n" 


               {- VALIDAZIONE INPUT -}

{- Funzione che, acquisiti dei caratteri da tastiera, verifica se sono solamente numeri interi
   Nel caso dovessero essere stati inseriti altri valori viene comunicato all'utente e 
   si attende per nuovi dati in input -}

acquisisciInt :: IO Int
acquisisciInt = do
  testo <- getLine
  case readMaybe testo of
    Just x -> return x
    Nothing -> putStrLn "\nErrore\nNb. Inserire solo numeri interi:\n">>acquisisciInt


{- Funzione che, acquisiti dei caratteri da tastiera, verifica se sono state inserite
   solo lettere MAIUSCOLE, minuscole e spazi
   Nel caso fossero stati inseriti altri caratteri al di fuori di questi ultimi verrà chiesto all'utente
   di inserire un nuovo testo -}

acquisisciStringa :: IO String
acquisisciStringa = do 
  inputTesto <- getLine
  let testo = read inputTesto
  case controlloTesto testo of
   True -> return testo
   False -> putStrLn "\nErrore\nInserire solo lettere MAIUSCOLE, minuscole e spazi:\n">>acquisisciStringa


{- Funzione che tramite un'altra funzione controlla che tutti i caratteri 
   di una lista rientrino tra le possibilita' accettate -}

controlloTesto :: [Char] -> Bool
controlloTesto = all controlloLettera


{- Funzione che controlla se un carattere rientra tra le lettere MAIUSCOLE, minuscole o spazio
   se il carattere rientra tra questi la funzione ritorna True, altrimenti False  -}

controlloLettera :: Char -> Bool
controlloLettera x
     | x `elem` [' '] = True 
     | x `elem` ['a'..'z'] = True
     | x `elem` ['A'..'Z'] = True
     | otherwise           = False


          {- CIFRATURA E DECIFRATURA -}

{- Restituisce il valore della posizione di una lettera nell'alfabeto
   Parte da 0 perciò 'a' avrà valore 0
   Possono essere lette sia lettere minuscole che maiuscole  -}

posizione :: Char -> Maybe Int
posizione carattere = elemIndex (toLower carattere) ['a'..'z']


{- Trova l'n-esimo carattere dell'alfabeto e lo racchiude tra indici
   Restituisce solamente lettere minuscole -}

lettera :: Int -> Maybe Char
lettera indice = lookup (abs $ indice `mod` 26) (zip [0..] ['a'..'z'])


{- Data una chiave, crittografa la stringa data utilizzando la crittografia di Vigenère
   Una chiave più corta rispetto al testo da cifrare verrà ripetuta in modo da poter 
   cifrare tutto il testo
   Restituirà sempre lettere minuscole poiché utilizza 'lettera'  -}

vigenere :: String -> String -> String
vigenere = zipWith shift.cycle
    where
      shift chiave testo =
          fromMaybe testo $
          do posT <- posizione testo
             posC <- posizione chiave
             lettera $ posT + posC


{- Questa funzione è essenzialmente l'inverso della precedente 'vigenere'  -}

unvigenere :: String -> String -> String
unvigenere = zipWith unshift.cycle
    where
      unshift chiave testo =
          fromMaybe testo $
          do posT <- posizione testo
             posC <- posizione chiave
             lettera $ posT - posC