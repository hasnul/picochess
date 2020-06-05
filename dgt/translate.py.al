# Copyright (C) 2013-2018 Jean-Francois Romang (jromang@posteo.de)
#                         Shivkumar Shivaji ()
#                         Jürgen Précour (LocutusOfPenguin@posteo.de)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import logging
from dgt.util import Beep, BeepLevel
from dgt.api import Dgt


class DgtTranslate(object):

    """Handle translations for clock texts or moves."""

    def __init__(self, beep_config: str, beep_level: int, language: str, picochess_version: str):
        self.ConfigToBeep = {'all': Beep.ON, 'none': Beep.OFF, 'some': Beep.SOME}
        self.beep = self.ConfigToBeep[beep_config]
        self.beep_level = beep_level
        self.language = language
        self.version = picochess_version
        self.capital = False  # Set from dgt.menu lateron
        self.notation = False  # Set from dgt.menu lateron

    def beep_to_config(self, beep: Beep):
        """Transfer beep to dict."""
        return dict(zip(self.ConfigToBeep.values(), self.ConfigToBeep.keys()))[beep]

    def bl(self, beeplevel: BeepLevel):
        """Transfer beeplevel to bool."""
        if self.beep == Beep.ON:
            return True
        if self.beep == Beep.OFF:
            return False
        return bool(self.beep_level & beeplevel.value)

    def set_beep(self, beep: Beep):
        """Set beep."""
        self.beep = beep

    def set_language(self, language: str):
        """Set language."""
        self.language = language

    def set_capital(self, capital: bool):
        """Set capital letters."""
        self.capital = capital

    def capital_text(self, text, is_obj=True):
        """Transfer text to capital text or not."""
        if self.capital:
            if is_obj:
                text.m = text.m.upper()
                text.l = text.l.upper()
            else:
                return text.upper()
        return text

    def set_notation(self, notation: bool):
        """Set notation."""
        self.notation = notation

    def text(self, str_code: str, msg='', devs=None):
        """Return standard text for clock display."""
        if devs is None:  # prevent W0102 error
            devs = {'ser', 'i2c', 'web'}

        entxt = detxt = nltxt = frtxt = estxt = ittxt = eutxt = None  # error case

        (code, text_id) = str_code.split('_', 1)
        if code[0] == 'B':
            beep = self.bl(BeepLevel.BUTTON)
        elif code[0] == 'N':
            beep = self.bl(BeepLevel.NO)
        elif code[0] == 'Y':
            beep = self.bl(BeepLevel.YES)
        elif code[0] == 'K':
            beep = self.bl(BeepLevel.OKAY)
        elif code[0] == 'C':
            beep = self.bl(BeepLevel.CONFIG)
        elif code[0] == 'M':
            beep = self.bl(BeepLevel.MAP)
        else:
            beep = False
        maxtime = int(code[1:]) / 10
        wait = False

        if text_id == 'default':
            entxt = Dgt.DISPLAY_TEXT(l=msg, m=msg[:8], s=msg[:6])
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = entxt
        if text_id == 'restoregame':
            entxt = Dgt.DISPLAY_TEXT(l='read game..', m='readGame', s='r game')
            detxt = Dgt.DISPLAY_TEXT(l='Letzt Spiel', m='letSpiel', s='lSpiel')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Jokoa iraku', m='JokoaIra', s='J irak')
        if text_id == 'goodbye':
            entxt = Dgt.DISPLAY_TEXT(l='Good bye   ', m='Good bye', s='bye   ')
            detxt = Dgt.DISPLAY_TEXT(l='Tschuess   ', m='Tschuess', s='tschau')
            nltxt = Dgt.DISPLAY_TEXT(l='tot ziens  ', m='totziens', s='dag   ')
            frtxt = Dgt.DISPLAY_TEXT(l='au revoir  ', m='a plus  ', s='bye   ')
            estxt = Dgt.DISPLAY_TEXT(l='adios      ', m='adios   ', s='adios ')
            ittxt = Dgt.DISPLAY_TEXT(l='arrivederci', m='a presto', s='ciao  ')
            eutxt = Dgt.DISPLAY_TEXT(l='Agur       ', m='Agur    ', s='Agur  ')
        if text_id == 'pleasewait':
            entxt = Dgt.DISPLAY_TEXT(l='please wait', m='pls wait', s='wait  ')
            detxt = Dgt.DISPLAY_TEXT(l='bitteWarten', m='warten  ', s='warten')
            nltxt = Dgt.DISPLAY_TEXT(l='wacht even ', m='wachten ', s='wacht ')
            frtxt = Dgt.DISPLAY_TEXT(l='patientez  ', m='patience', s='patien')
            estxt = Dgt.DISPLAY_TEXT(l='espere     ', m='espere  ', s='espere')
            ittxt = Dgt.DISPLAY_TEXT(l='un momento ', m='attendi ', s='attesa')
            eutxt = Dgt.DISPLAY_TEXT(l='Itxaron    ', m='Itxaron ', s='Itxoin')
        if text_id == 'nomove':
            entxt = Dgt.DISPLAY_TEXT(l='no move    ', m='no move ', s='nomove')
            detxt = Dgt.DISPLAY_TEXT(l='Kein Zug   ', m='Kein Zug', s='kn zug')
            nltxt = Dgt.DISPLAY_TEXT(l='Geen zet   ', m='Geen zet', s='gn zet')
            frtxt = Dgt.DISPLAY_TEXT(l='pas de mouv', m='pas mvt ', s='pasmvt')
            estxt = Dgt.DISPLAY_TEXT(l='sin mov    ', m='sin mov ', s='no mov')
            ittxt = Dgt.DISPLAY_TEXT(l='no mossa   ', m='no mossa', s='nmossa')
            eutxt = Dgt.DISPLAY_TEXT(l='Mugimen. ez', m='Mugi. ez', s='Mug ez')
        if text_id == 'wb':
            entxt = Dgt.DISPLAY_TEXT(l=' W       B ', m=' W     B', s='wh  bl')
            detxt = Dgt.DISPLAY_TEXT(l=' W       S ', m=' W     S', s='we  sc')
            nltxt = Dgt.DISPLAY_TEXT(l=' W       Z ', m=' W     Z', s='wi  zw')
            frtxt = Dgt.DISPLAY_TEXT(l=' B       N ', m=' B     N', s='bl  no')
            estxt = Dgt.DISPLAY_TEXT(l=' B       N ', m=' B     N', s='bl  ne')
            ittxt = Dgt.DISPLAY_TEXT(l=' B       N ', m=' B     N', s='bi  ne')
            eutxt = Dgt.DISPLAY_TEXT(l=' Z       B ', m=' Z     B', s='zu  be')
        if text_id == 'bw':
            entxt = Dgt.DISPLAY_TEXT(l=' B       W ', m=' B     W', s='bl  wh')
            detxt = Dgt.DISPLAY_TEXT(l=' S       W ', m=' S     W', s='sc  we')
            nltxt = Dgt.DISPLAY_TEXT(l=' Z       W ', m=' Z     W', s='zw  wi')
            frtxt = Dgt.DISPLAY_TEXT(l=' N       B ', m=' N     B', s='no  bl')
            estxt = Dgt.DISPLAY_TEXT(l=' N       B ', m=' N     B', s='ne  bl')
            ittxt = Dgt.DISPLAY_TEXT(l=' N       B ', m=' N     B', s='ne  bi')
            eutxt = Dgt.DISPLAY_TEXT(l=' B       Z ', m=' B     Z', s='be  zu')
        if text_id == '960no':
            entxt = Dgt.DISPLAY_TEXT(l='uci960 no  ', m='960 no  ', s='960 no')
            detxt = Dgt.DISPLAY_TEXT(l='uci960 nein', m='960 nein', s='960 nn')
            nltxt = Dgt.DISPLAY_TEXT(l='uci960 nee ', m='960 nee ', s='960nee')
            frtxt = Dgt.DISPLAY_TEXT(l='uci960 non ', m='960 non ', s='960non')
            estxt = Dgt.DISPLAY_TEXT(l='uci960 no  ', m='960 no  ', s='960 no')
            ittxt = Dgt.DISPLAY_TEXT(l='uci960 no  ', m='960 no  ', s='960 no')
            eutxt = Dgt.DISPLAY_TEXT(l='uci960 ez  ', m='960 ez  ', s='960 ez')
        if text_id == '960yes':
            entxt = Dgt.DISPLAY_TEXT(l='uci960 yes ', m='960 yes ', s='960yes')
            detxt = Dgt.DISPLAY_TEXT(l='uci960 ja  ', m='960 ja  ', s='960 ja')
            nltxt = Dgt.DISPLAY_TEXT(l='uci960 ja  ', m='960 ja  ', s='960 ja')
            frtxt = Dgt.DISPLAY_TEXT(l='uci960 oui ', m='960 oui ', s='960oui')
            estxt = Dgt.DISPLAY_TEXT(l='uci960 si  ', m='960 si  ', s='960 si')
            ittxt = Dgt.DISPLAY_TEXT(l='uci960 si  ', m='960 si  ', s='960 si')
            eutxt = Dgt.DISPLAY_TEXT(l='uci960 bai ', m='960 bai ', s='960bai')
        if text_id == 'picochess':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='PicoChs ' + self.version, m='pico ' + self.version, s='pic' + self.version)
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = entxt
        if text_id == 'nofunction':
            entxt = Dgt.DISPLAY_TEXT(l='no function', m='no funct', s='nofunc')
            detxt = Dgt.DISPLAY_TEXT(l='Keine Funkt', m='KeineFkt', s='kn fkt')
            nltxt = Dgt.DISPLAY_TEXT(l='Geenfunctie', m='Geen fnc', s='gn fnc')
            frtxt = Dgt.DISPLAY_TEXT(l='no fonction', m='no fonct', s='nofonc')
            estxt = Dgt.DISPLAY_TEXT(l='sin funcion', m='sin func', s='nofunc')
            ittxt = Dgt.DISPLAY_TEXT(l='no funzione', m='no funz ', s='nofunz')
            eutxt = Dgt.DISPLAY_TEXT(l='funtzioGabe', m='ez funtz', s='ezfunt')
        if text_id == 'erroreng':
            entxt = Dgt.DISPLAY_TEXT(l='err engine ', m='err engn', s='erreng')
            detxt = Dgt.DISPLAY_TEXT(l='err engine ', m='err engn', s='erreng')
            nltxt = Dgt.DISPLAY_TEXT(l='fout engine', m='fout eng', s='e fout')
            frtxt = Dgt.DISPLAY_TEXT(l='err moteur ', m='err mot ', s='errmot')
            estxt = Dgt.DISPLAY_TEXT(l='error motor', m='err mot ', s='errmot')
            ittxt = Dgt.DISPLAY_TEXT(l='err motore ', m='err moto', s='errmot')
            eutxt = Dgt.DISPLAY_TEXT(l='err motorra', m='err moto', s='errmot')
        if text_id == 'okengine':
            entxt = Dgt.DISPLAY_TEXT(l='ok engine  ', m='okengine', s='ok eng')
            detxt = Dgt.DISPLAY_TEXT(l='ok engine  ', m='okengine', s='ok eng')
            nltxt = Dgt.DISPLAY_TEXT(l='ok engine  ', m='okengine', s='ok eng')
            frtxt = Dgt.DISPLAY_TEXT(l='ok moteur  ', m='ok mot  ', s='ok mot')
            estxt = Dgt.DISPLAY_TEXT(l='ok motor   ', m='ok motor', s='ok mot')
            ittxt = Dgt.DISPLAY_TEXT(l='ok motore  ', m='ok motor', s='ok mot')
            eutxt = Dgt.DISPLAY_TEXT(l='ok motorra ', m='ok motor', s='ok mot')
        if text_id == 'okmode':
            entxt = Dgt.DISPLAY_TEXT(l='ok mode    ', m='ok mode ', s='okmode')
            detxt = Dgt.DISPLAY_TEXT(l='ok Modus   ', m='ok Modus', s='okmode')
            nltxt = Dgt.DISPLAY_TEXT(l='ok modus   ', m='ok modus', s='okmode')
            frtxt = Dgt.DISPLAY_TEXT(l='ok mode    ', m='ok mode ', s='okmode')
            estxt = Dgt.DISPLAY_TEXT(l='ok modo    ', m='ok modo ', s='okmodo')
            ittxt = Dgt.DISPLAY_TEXT(l='ok modo    ', m='ok modo ', s='okmodo')
            eutxt = Dgt.DISPLAY_TEXT(l='ok modua   ', m='ok modua', s='okmodu')
        if text_id == 'okbook':
            entxt = Dgt.DISPLAY_TEXT(l='ok book    ', m='ok book ', s='okbook')
            detxt = Dgt.DISPLAY_TEXT(l='ok Buch    ', m='ok Buch ', s='okbuch')
            nltxt = Dgt.DISPLAY_TEXT(l='ok boek    ', m='ok boek ', s='okboek')
            frtxt = Dgt.DISPLAY_TEXT(l='ok livre   ', m='ok livre', s='ok liv')
            estxt = Dgt.DISPLAY_TEXT(l='ok libro   ', m='ok libro', s='oklibr')
            ittxt = Dgt.DISPLAY_TEXT(l='ok libroape', m='ok libro', s='oklibr')
            eutxt = Dgt.DISPLAY_TEXT(l='ok liburua ', m='ok libur', s='oklibu')
        if text_id == 'noipadr':
            entxt = Dgt.DISPLAY_TEXT(l='no IP addr ', m='no IPadr', s='no ip ')
            detxt = Dgt.DISPLAY_TEXT(l='Keine IPadr', m='Keine IP', s='kn ip ')
            nltxt = Dgt.DISPLAY_TEXT(l='Geen IPadr ', m='Geen IP ', s='gn ip ')
            frtxt = Dgt.DISPLAY_TEXT(l='pas d IP   ', m='pas d IP', s='pd ip ')
            estxt = Dgt.DISPLAY_TEXT(l='no IP dir  ', m='no IP   ', s='no ip ')
            ittxt = Dgt.DISPLAY_TEXT(l='no indir ip', m='no ip   ', s='no ip ')
            eutxt = Dgt.DISPLAY_TEXT(l='ez IP helbi', m='ez ip   ', s='ez ip ')
        if text_id == 'exitmenu':
            entxt = Dgt.DISPLAY_TEXT(l='exit menu  ', m='exitmenu', s='exit m')
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='utzi Menua ', m='utzimenu', s='utzi m')
        if text_id == 'errormenu':
            entxt = Dgt.DISPLAY_TEXT(l='error menu ', m='err menu', s='errmen')
            detxt = Dgt.DISPLAY_TEXT(l='error Menu ', m='err Menu', s='errmen')
            nltxt = Dgt.DISPLAY_TEXT(l='fout menu  ', m='foutmenu', s='fout m')
            frtxt = Dgt.DISPLAY_TEXT(l='error menu ', m='err menu', s='pd men')
            estxt = Dgt.DISPLAY_TEXT(l='error menu ', m='err menu', s='errmen')
            ittxt = Dgt.DISPLAY_TEXT(l='errore menu', m='err menu', s='errmen')
            eutxt = Dgt.DISPLAY_TEXT(l='err.  menua', m='errMenua', s='errmen')
        if text_id == 'sidewhite':
            entxt = Dgt.DISPLAY_TEXT(l='side move W', m='side W  ', s='side w')
            detxt = Dgt.DISPLAY_TEXT(l='W am Zug   ', m='W am Zug', s=' w zug')
            nltxt = Dgt.DISPLAY_TEXT(l='wit aan zet', m='wit zet ', s=' w zet')
            frtxt = Dgt.DISPLAY_TEXT(l='aux blancs ', m='mvt bl  ', s='mvt bl')
            estxt = Dgt.DISPLAY_TEXT(l='lado blanco', m='lado W  ', s='lado w')
            ittxt = Dgt.DISPLAY_TEXT(l='lato bianco', m='lato b  ', s='lato b')
            eutxt = Dgt.DISPLAY_TEXT(l='zuri aldea ', m='aldea Z ', s='aldeaZ')
        if text_id == 'sideblack':
            entxt = Dgt.DISPLAY_TEXT(l='side move B', m='side B  ', s='side b')
            detxt = Dgt.DISPLAY_TEXT(l='S am Zug   ', m='S am Zug', s=' s zug')
            nltxt = Dgt.DISPLAY_TEXT(l='zw aan zet ', m='zw zet  ', s=' z zet')
            frtxt = Dgt.DISPLAY_TEXT(l='aux noirs  ', m='mvt n   ', s='mvt n ')
            estxt = Dgt.DISPLAY_TEXT(l='lado negro ', m='lado B  ', s='lado b')
            ittxt = Dgt.DISPLAY_TEXT(l='lato nero  ', m='lato n  ', s='lato n')
            eutxt = Dgt.DISPLAY_TEXT(l='beltz aldea', m='aldea B ', s='aldeaB')
        if text_id == 'scanboard':
            entxt = Dgt.DISPLAY_TEXT(l='scan board ', m='scan    ', s='scan  ')
            detxt = Dgt.DISPLAY_TEXT(l='lese Stellg', m='lese Stl', s='lese s')
            nltxt = Dgt.DISPLAY_TEXT(l='scan bord  ', m='scan    ', s='scan  ')
            frtxt = Dgt.DISPLAY_TEXT(l='scan echiq ', m='scan    ', s='scan  ')
            estxt = Dgt.DISPLAY_TEXT(l='escan tabl ', m='escan   ', s='escan ')
            ittxt = Dgt.DISPLAY_TEXT(l='scan scacch', m='scan    ', s='scan  ')
            eutxt = Dgt.DISPLAY_TEXT(l='taula eskan', m='eskanea ', s='eskane')
        if text_id == 'illegalpos':
            entxt = Dgt.DISPLAY_TEXT(l='invalid pos', m='invalid ', s='badpos')
            detxt = Dgt.DISPLAY_TEXT(l='illegalePos', m='illegal ', s='errpos')
            nltxt = Dgt.DISPLAY_TEXT(l='ongeldig   ', m='ongeldig', s='ongeld')
            frtxt = Dgt.DISPLAY_TEXT(l='illegale   ', m='illegale', s='pos il')
            estxt = Dgt.DISPLAY_TEXT(l='illegal pos', m='ileg pos', s='errpos')
            ittxt = Dgt.DISPLAY_TEXT(l='pos illegal', m='illegale', s='errpos')
            eutxt = Dgt.DISPLAY_TEXT(l='pos ilegala', m='ilegala ', s='errpos')
        if text_id == 'error960':
            entxt = Dgt.DISPLAY_TEXT(l='err uci960 ', m='err 960 ', s='err960')
            detxt = Dgt.DISPLAY_TEXT(l='err uci960 ', m='err 960 ', s='err960')
            nltxt = Dgt.DISPLAY_TEXT(l='fout uci960', m='fout 960', s='err960')
            frtxt = Dgt.DISPLAY_TEXT(l='err uci960 ', m='err 960 ', s='err960')
            estxt = Dgt.DISPLAY_TEXT(l='err uci960 ', m='err 960 ', s='err960')
            ittxt = Dgt.DISPLAY_TEXT(l='errore 960 ', m='erro 960', s='err960')
            eutxt = Dgt.DISPLAY_TEXT(l='errorea 960', m='erro 960', s='err960')
        if text_id == 'oktime':
            entxt = Dgt.DISPLAY_TEXT(l='ok time    ', m='ok time ', s='ok tim')
            detxt = Dgt.DISPLAY_TEXT(l='ok Zeit    ', m='ok Zeit ', s='okzeit')
            nltxt = Dgt.DISPLAY_TEXT(l='ok tyd     ', m='ok tyd  ', s='ok tyd')
            frtxt = Dgt.DISPLAY_TEXT(l='ok temps   ', m='ok temps', s='ok tps')
            estxt = Dgt.DISPLAY_TEXT(l='ok tiempo  ', m='okTiempo', s='ok tpo')
            ittxt = Dgt.DISPLAY_TEXT(l='ok tempo   ', m='ok tempo', s='oktemp')
            eutxt = Dgt.DISPLAY_TEXT(l='ok denbora ', m='ok denbo', s='okDenb')
        if text_id == 'okbeep':
            entxt = Dgt.DISPLAY_TEXT(l='ok beep    ', m='ok beep ', s='okbeep')
            detxt = Dgt.DISPLAY_TEXT(l='ok Toene   ', m='ok Toene', s='ok ton')
            nltxt = Dgt.DISPLAY_TEXT(l='ok piep    ', m='ok piep ', s='okpiep')
            frtxt = Dgt.DISPLAY_TEXT(l='ok sons    ', m='ok sons ', s='oksons')
            estxt = Dgt.DISPLAY_TEXT(l='ok beep    ', m='ok beep ', s='okbeep')
            ittxt = Dgt.DISPLAY_TEXT(l='ok beep    ', m='ok beep ', s='okbeep')
            ittxt = Dgt.DISPLAY_TEXT(l='ok beep    ', m='ok beep ', s='okbeep')
            eutxt = Dgt.DISPLAY_TEXT(l='ok beep    ', m='ok beep ', s='okbeep')
        if text_id == 'okpico':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='ok pico    ', m='ok pico ', s='okpico')
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = entxt
        if text_id == 'okuser':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='ok player  ', m='okplayer', s='okplay')
            detxt = Dgt.DISPLAY_TEXT(l='ok Spieler ', m='ok Splr ', s='oksplr')
            nltxt = Dgt.DISPLAY_TEXT(l='ok Speler  ', m='okSpeler', s='oksplr')
            frtxt = Dgt.DISPLAY_TEXT(l='ok joueur  ', m='okjoueur', s='ok jr ')
            estxt = Dgt.DISPLAY_TEXT(l='ok usuario ', m='okusuari', s='okuser')
            ittxt = Dgt.DISPLAY_TEXT(l='ok utente  ', m='ok utent', s='okuten')
            eutxt = Dgt.DISPLAY_TEXT(l='ok erabiltz', m='ok erabi', s='okuser')
        if text_id == 'okmove':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='ok move    ', m='ok move ', s='okmove')
            detxt = Dgt.DISPLAY_TEXT(l='ok Zug     ', m='ok Zug  ', s='ok zug')
            nltxt = Dgt.DISPLAY_TEXT(l='ok zet     ', m='ok zet  ', s='ok zet')
            frtxt = Dgt.DISPLAY_TEXT(l='ok mouv    ', m='ok mouv ', s='ok mvt')
            estxt = Dgt.DISPLAY_TEXT(l='ok jugada  ', m='okjugada', s='ok jug')
            ittxt = Dgt.DISPLAY_TEXT(l='mossa ok   ', m='mossa ok', s='ok mos')
            eutxt = Dgt.DISPLAY_TEXT(l='jokaldia ok', m='mugim ok', s='ok mug')
        if text_id == 'altmove':
            entxt = Dgt.DISPLAY_TEXT(l='altn move  ', m='alt move', s='altmov')
            detxt = Dgt.DISPLAY_TEXT(l='altnatv Zug', m='alt Zug ', s='altzug')
            nltxt = Dgt.DISPLAY_TEXT(l='andere zet ', m='alt zet ', s='altzet')
            frtxt = Dgt.DISPLAY_TEXT(l='autre mouv ', m='alt move', s='altmov')
            estxt = Dgt.DISPLAY_TEXT(l='altn jugada', m='altjugad', s='altjug')
            ittxt = Dgt.DISPLAY_TEXT(l='mossa alter', m='mossa al', s='mosalt')
            eutxt = Dgt.DISPLAY_TEXT(l='ordez jokal', m='mugi ord', s='mugOrd')
        if text_id == 'newgame':
            wait = True  # in case of GAME_ENDS before, wait for "abort"
            entxt = Dgt.DISPLAY_TEXT(l='new Game   ', m='new Game', s='newgam')
            detxt = Dgt.DISPLAY_TEXT(l='neues Spiel', m='neuesSpl', s='neuspl')
            nltxt = Dgt.DISPLAY_TEXT(l='nieuw party', m='nw party', s='nwpart')
            frtxt = Dgt.DISPLAY_TEXT(l='nvl partie ', m='nvl part', s='newgam')
            estxt = Dgt.DISPLAY_TEXT(l='nuev partid', m='nuevpart', s='nuepar')
            ittxt = Dgt.DISPLAY_TEXT(l='nuova parti', m='nuo part', s='nuopar')
            eutxt = Dgt.DISPLAY_TEXT(l='partiBerria', m='parBerri', s='p Berr')
        if text_id == 'ucigame':
            wait = True
            msg = msg.rjust(3)
            entxt = Dgt.DISPLAY_TEXT(l='new Game' + msg, m='Game ' + msg, s='gam' + msg)
            detxt = Dgt.DISPLAY_TEXT(l='neuSpiel' + msg, m='Spiel' + msg, s='spl' + msg)
            nltxt = Dgt.DISPLAY_TEXT(l='nw party' + msg, m='party' + msg, s='par' + msg)
            frtxt = Dgt.DISPLAY_TEXT(l='nvl part' + msg, m='part ' + msg, s='gam' + msg)
            estxt = Dgt.DISPLAY_TEXT(l='partid  ' + msg, m='part ' + msg, s='par' + msg)
            ittxt = Dgt.DISPLAY_TEXT(l='nuo part' + msg, m='part ' + msg, s='par' + msg)
            eutxt = Dgt.DISPLAY_TEXT(l='partida ' + msg, m='part ' + msg, s='par' + msg)
        if text_id == 'takeback':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='takeback   ', m='takeback', s='takbak')
            detxt = Dgt.DISPLAY_TEXT(l='Ruecknahme ', m='Rcknahme', s='rueckn')
            nltxt = Dgt.DISPLAY_TEXT(l='zet terug  ', m='zetterug', s='terug ')
            frtxt = Dgt.DISPLAY_TEXT(l='retour     ', m='retour  ', s='retour')
            estxt = Dgt.DISPLAY_TEXT(l='retrocede  ', m='atras   ', s='atras ')
            ittxt = Dgt.DISPLAY_TEXT(l='ritorna    ', m='ritorna ', s='ritorn')
            eutxt = Dgt.DISPLAY_TEXT(l='atzera egin', m='atzera  ', s='atzera')
        if text_id == 'bookmove':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='book       ', m='book    ', s='book  ')
            detxt = Dgt.DISPLAY_TEXT(l='Buch       ', m='Buch    ', s='buch  ')
            nltxt = Dgt.DISPLAY_TEXT(l='boek       ', m='boek    ', s='boek  ')
            frtxt = Dgt.DISPLAY_TEXT(l='livre      ', m='livre   ', s='livre ')
            estxt = Dgt.DISPLAY_TEXT(l='libro      ', m='libro   ', s='libro ')
            ittxt = Dgt.DISPLAY_TEXT(l='libro      ', m='libro   ', s='libro ')
            eutxt = Dgt.DISPLAY_TEXT(l='liburua    ', m='liburua ', s='liburu')
        if text_id == 'setpieces':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='set pieces ', m='set pcs ', s='setpcs')
            detxt = Dgt.DISPLAY_TEXT(l='St aufbauen', m='aufbauen', s='aufbau')
            nltxt = Dgt.DISPLAY_TEXT(l='zet stukken', m='zet stkn', s='zet st')
            frtxt = Dgt.DISPLAY_TEXT(l='placer pcs ', m='set pcs ', s='setpcs')
            estxt = Dgt.DISPLAY_TEXT(l='Poner piez ', m='poner pz', s='pon pz')
            ittxt = Dgt.DISPLAY_TEXT(l='sistema pez', m='sistpezz', s='sispez')
            eutxt = Dgt.DISPLAY_TEXT(l='jarri pieza', m='jar piez', s='jarPza')
        if text_id == 'errorjack':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='error jack ', m='err jack', s='jack  ')
            detxt = Dgt.DISPLAY_TEXT(l='err Kabel  ', m='errKabel', s='errkab')
            nltxt = Dgt.DISPLAY_TEXT(l='fout Kabel ', m='errKabel', s='errkab')
            frtxt = Dgt.DISPLAY_TEXT(l='jack error ', m='jack err', s='jack  ')
            estxt = Dgt.DISPLAY_TEXT(l='jack error ', m='jack err', s='jack  ')
            ittxt = Dgt.DISPLAY_TEXT(l='errore jack', m='err jack', s='jack  ')
            eutxt = Dgt.DISPLAY_TEXT(l='erroreajack', m='err jack', s='jack  ')
        if text_id == 'errorroom':
            entxt = Dgt.DISPLAY_TEXT(l='error room ', m='err room', s='noroom')
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='errora gela', m='err gela', s='ezgela')
        if text_id == 'errormode':
            entxt = Dgt.DISPLAY_TEXT(l='error mode ', m='err mode', s='errmod')
            detxt = Dgt.DISPLAY_TEXT(l='error Modus', m='errModus', s='errmod')
            nltxt = Dgt.DISPLAY_TEXT(l='fout modus ', m='fout mod', s='errmod')
            frtxt = Dgt.DISPLAY_TEXT(l='error mode ', m='err mode', s='errmod')
            estxt = Dgt.DISPLAY_TEXT(l='error modo ', m='err modo', s='errmod')
            ittxt = Dgt.DISPLAY_TEXT(l='errore modo', m='err modo', s='errmod')
            eutxt = Dgt.DISPLAY_TEXT(l='err   modua', m='errmodua', s='errmod')
        if text_id == 'level':
            if msg.startswith('Elo@'):
                msg = str(int(msg[4:])).rjust(4)
                entxt = Dgt.DISPLAY_TEXT(l='Elo ' + msg, m='Elo ' + msg, s='el' + msg)
                detxt = entxt
                nltxt = entxt
                frtxt = entxt
                estxt = entxt
                ittxt = entxt
                eutxt = entxt
            elif msg.startswith('Level@'):
                msg = str(int(msg[6:])).rjust(2)
                entxt = Dgt.DISPLAY_TEXT(l='level    ' + msg, m='level ' + msg, s='lvl ' + msg)
                detxt = Dgt.DISPLAY_TEXT(l='Level    ' + msg, m='Level ' + msg, s='stf ' + msg)
                nltxt = entxt
                frtxt = Dgt.DISPLAY_TEXT(l='niveau   ' + msg, m='niveau' + msg, s='niv ' + msg)
                estxt = Dgt.DISPLAY_TEXT(l='nivel    ' + msg, m='nivel ' + msg, s='nvl ' + msg)
                ittxt = Dgt.DISPLAY_TEXT(l='livello  ' + msg, m='livel ' + msg, s='liv ' + msg)
                eutxt = Dgt.DISPLAY_TEXT(l='maila    ' + msg, m='maila ' + msg, s='mai ' + msg)
            else:
                entxt = Dgt.DISPLAY_TEXT(l=msg, m=msg[:8], s=msg[:6])
                detxt = entxt
                nltxt = entxt
                frtxt = entxt
                estxt = entxt
                ittxt = entxt
                eutxt = entxt
        if text_id == 'mate':
            entxt = Dgt.DISPLAY_TEXT(l='mate in ' + msg, m='mate ' + msg, s='mat' + msg)
            detxt = Dgt.DISPLAY_TEXT(l='Matt in ' + msg, m='Matt ' + msg, s='mat' + msg)
            nltxt = Dgt.DISPLAY_TEXT(l='mat in  ' + msg, m='mat  ' + msg, s='mat' + msg)
            frtxt = Dgt.DISPLAY_TEXT(l='mat en  ' + msg, m='mat  ' + msg, s='mat' + msg)
            estxt = Dgt.DISPLAY_TEXT(l='mate en ' + msg, m='mate ' + msg, s='mat' + msg)
            ittxt = Dgt.DISPLAY_TEXT(l='matto in' + msg, m='matto' + msg, s='mat' + msg)
            eutxt = Dgt.DISPLAY_TEXT(l='matea   ' + msg, m='matea' + msg, s='mat' + msg)
        if text_id == 'score':
            text_s = 'no scr' if msg is None else str(msg).rjust(6)
            text_m = 'no score' if msg is None else str(msg).rjust(8)
            entxt = Dgt.DISPLAY_TEXT(l=text_m.rjust(11), m=text_m, s=text_s)
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = entxt
        if text_id == 'top_mode_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Mode       ', m='Mode    ', s='mode  ')
            detxt = Dgt.DISPLAY_TEXT(l='Modus      ', m='Modus   ', s='modus ')
            nltxt = Dgt.DISPLAY_TEXT(l='Modus      ', m='Modus   ', s='modus ')
            frtxt = Dgt.DISPLAY_TEXT(l='Mode       ', m='Mode    ', s='mode  ')
            estxt = Dgt.DISPLAY_TEXT(l='Modo       ', m='Modo    ', s='modo  ')
            ittxt = Dgt.DISPLAY_TEXT(l='Modo       ', m='Modo    ', s='modo  ')
            eutxt = Dgt.DISPLAY_TEXT(l='Modua      ', m='Modua   ', s='modua ')
        if text_id == 'top_position_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Position   ', m='Position', s='posit ')
            detxt = Dgt.DISPLAY_TEXT(l='Position   ', m='Position', s='positn')
            nltxt = Dgt.DISPLAY_TEXT(l='Stelling   ', m='Stelling', s='stelng')
            frtxt = Dgt.DISPLAY_TEXT(l='Position   ', m='Position', s='posit ')
            estxt = Dgt.DISPLAY_TEXT(l='Posicion   ', m='Posicion', s='posic ')
            ittxt = Dgt.DISPLAY_TEXT(l='Posizione  ', m='Posizion', s='posizi')
            eutxt = Dgt.DISPLAY_TEXT(l='Posizioa   ', m='Posizioa', s='posizi')
        if text_id == 'top_time_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Time       ', m='Time    ', s='time  ')
            detxt = Dgt.DISPLAY_TEXT(l='Zeit       ', m='Zeit    ', s='zeit  ')
            nltxt = Dgt.DISPLAY_TEXT(l='Tyd        ', m='Tyd     ', s='tyd   ')
            frtxt = Dgt.DISPLAY_TEXT(l='Temps      ', m='Temps   ', s='temps ')
            estxt = Dgt.DISPLAY_TEXT(l='Tiempo     ', m='Tiempo  ', s='tiempo')
            ittxt = Dgt.DISPLAY_TEXT(l='Tempo      ', m='Tempo   ', s='tempo ')
            eutxt = Dgt.DISPLAY_TEXT(l='Denbora    ', m='Denbora ', s='denbor')
        if text_id == 'top_book_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Book       ', m='Book    ', s='book  ')
            detxt = Dgt.DISPLAY_TEXT(l='Buch       ', m='Buch    ', s='buch  ')
            nltxt = Dgt.DISPLAY_TEXT(l='Boek       ', m='Boek    ', s='boek  ')
            frtxt = Dgt.DISPLAY_TEXT(l='Livre      ', m='Livre   ', s='livre ')
            estxt = Dgt.DISPLAY_TEXT(l='Libro      ', m='Libro   ', s='libro ')
            ittxt = Dgt.DISPLAY_TEXT(l='Libro      ', m='Libro   ', s='libro ')
            eutxt = Dgt.DISPLAY_TEXT(l='Liburua    ', m='Liburua ', s='liburu')
        if text_id == 'top_engine_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Engine     ', m='Engine  ', s='engine')
            detxt = Dgt.DISPLAY_TEXT(l='Engine     ', m='Engine  ', s='engine')
            nltxt = Dgt.DISPLAY_TEXT(l='Engine     ', m='Engine  ', s='engine')
            frtxt = Dgt.DISPLAY_TEXT(l='Moteur     ', m='Moteur  ', s='moteur')
            estxt = Dgt.DISPLAY_TEXT(l='Motor      ', m='Motor   ', s='motor ')
            ittxt = Dgt.DISPLAY_TEXT(l='Motore     ', m='Motore  ', s='motore')
            eutxt = Dgt.DISPLAY_TEXT(l='Motorra    ', m='Motorra ', s='motorr')
        if text_id == 'top_system_menu':
            entxt = Dgt.DISPLAY_TEXT(l='System     ', m='System  ', s='system')
            detxt = Dgt.DISPLAY_TEXT(l='System     ', m='System  ', s='system')
            nltxt = Dgt.DISPLAY_TEXT(l='Systeem    ', m='Systeem ', s='system')
            frtxt = Dgt.DISPLAY_TEXT(l='Systeme    ', m='Systeme ', s='system')
            estxt = Dgt.DISPLAY_TEXT(l='Sistema    ', m='Sistema ', s='sistem')
            ittxt = Dgt.DISPLAY_TEXT(l='Sistema    ', m='Sistema ', s='sistem')
            eutxt = Dgt.DISPLAY_TEXT(l='Sistema    ', m='Sistema ', s='sistem')
        if text_id == 'mode_normal_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Normal     ', m='Normal  ', s='normal')
            detxt = Dgt.DISPLAY_TEXT(l='Normal     ', m='Normal  ', s='normal')
            nltxt = Dgt.DISPLAY_TEXT(l='Normaal    ', m='Normaal ', s='normal')
            frtxt = Dgt.DISPLAY_TEXT(l='Normal     ', m='Normal  ', s='normal')
            estxt = Dgt.DISPLAY_TEXT(l='Normal     ', m='Normal  ', s='normal')
            ittxt = Dgt.DISPLAY_TEXT(l='Normale    ', m='Normale ', s='normal')
            eutxt = Dgt.DISPLAY_TEXT(l='Normala    ', m='Normala ', s='normal')
        if text_id == 'mode_training_menu': # WD
            entxt = Dgt.DISPLAY_TEXT(l='Training   ', m='Training', s='train') # WD
            detxt = Dgt.DISPLAY_TEXT(l='Training   ', m='Training', s='train') # WD
            nltxt = entxt # WD
            frtxt = entxt # WD
            estxt = entxt # WD
            ittxt = entxt # WD
            eutxt = Dgt.DISPLAY_TEXT(l='Trebatu    ', m='Trebatu ', s='treba ') # WD
        if text_id == 'mode_brain_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Ponder on  ', m='PonderOn', s='ponder')
            detxt = Dgt.DISPLAY_TEXT(l='Ponder an  ', m='PonderAn', s='ponder')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Hausnartu  ', m='Hausnart', s='hausna')
        if text_id == 'mode_analysis_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Move hint  ', m='MoveHint', s='mvhint')
            detxt = Dgt.DISPLAY_TEXT(l='Zughinweis ', m='ZugVor. ', s='zugvor')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Mug.Iradoki', m='MugIradok', s='mgIrad')
        if text_id == 'mode_kibitz_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Eval.Score ', m='Score   ', s='score')
            detxt = Dgt.DISPLAY_TEXT(l='Bewertung  ', m='Bewert. ', s='bewert')
            nltxt = entxt
            frtxt = Dgt.DISPLAY_TEXT(l='Evaluer    ', m='Evaluer ', s='evalue')
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Ebaluatu   ', m='Ebaluatu', s='ebalua')
        if text_id == 'mode_observe_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Observe    ', m='Observe ', s='observ')
            detxt = Dgt.DISPLAY_TEXT(l='Beobachten ', m='Beobacht', s='beob. ')
            nltxt = Dgt.DISPLAY_TEXT(l='Observeren ', m='Observr ', s='observ')
            frtxt = Dgt.DISPLAY_TEXT(l='Observer   ', m='Observer', s='observ')
            estxt = Dgt.DISPLAY_TEXT(l='Observa    ', m='Observa ', s='observ')
            ittxt = Dgt.DISPLAY_TEXT(l='Osserva    ', m='Osserva ', s='osserv')
            eutxt = Dgt.DISPLAY_TEXT(l='Begiratu   ', m='Begiratu', s='begira')
        if text_id == 'mode_remote_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Remote     ', m='Remote  ', s='remote')
            detxt = Dgt.DISPLAY_TEXT(l='Remote     ', m='Remote  ', s='remote')
            nltxt = Dgt.DISPLAY_TEXT(l='Remote     ', m='Remote  ', s='remote')
            frtxt = Dgt.DISPLAY_TEXT(l='Remote     ', m='Remote  ', s='remote')
            estxt = Dgt.DISPLAY_TEXT(l='Remoto     ', m='Remoto  ', s='remoto')
            ittxt = Dgt.DISPLAY_TEXT(l='Remoto     ', m='Remoto  ', s='remoto')
            eutxt = Dgt.DISPLAY_TEXT(l='Urrutikoa  ', m='Urrutiko', s='urruti')
        if text_id == 'mode_ponder_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Analysis   ', m='Analysis', s='analys')
            detxt = Dgt.DISPLAY_TEXT(l='Analyse    ', m='Analyse ', s='analys')
            nltxt = Dgt.DISPLAY_TEXT(l='Analyseren ', m='Analyse ', s='analys')
            frtxt = Dgt.DISPLAY_TEXT(l='Analyser   ', m='Analyser', s='analys')
            estxt = Dgt.DISPLAY_TEXT(l='Analisis   ', m='Analisis', s='analis')
            ittxt = Dgt.DISPLAY_TEXT(l='Analisi    ', m='Analisi ', s='Analis')
            eutxt = Dgt.DISPLAY_TEXT(l='Analisia   ', m='Analisia', s='Analis')
        if text_id == 'timemode_fixed_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Move time  ', m='Movetime', s='move t')
            detxt = Dgt.DISPLAY_TEXT(l='Zugzeit    ', m='Zugzeit ', s='zug z ')
            nltxt = Dgt.DISPLAY_TEXT(l='Zet tyd    ', m='Zet tyd ', s='zet   ')
            frtxt = Dgt.DISPLAY_TEXT(l='Mouv temps ', m='Mouv tem', s='mouv  ')
            estxt = Dgt.DISPLAY_TEXT(l='Mov tiempo ', m='mov tiem', s='mov   ')
            ittxt = Dgt.DISPLAY_TEXT(l='Mossa tempo', m='Mosstemp', s='mostem')
            eutxt = Dgt.DISPLAY_TEXT(l='Mug Denbora', m='MugDenbo', s='mgdenb')
        if text_id == 'timemode_blitz_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Game time  ', m='Gametime', s='game t')
            detxt = Dgt.DISPLAY_TEXT(l='Spielzeit  ', m='Spielz  ', s='spielz')
            nltxt = Dgt.DISPLAY_TEXT(l='Spel tyd   ', m='Spel tyd', s='spel  ')
            frtxt = Dgt.DISPLAY_TEXT(l='Partie temp', m='Partie  ', s='partie')
            estxt = Dgt.DISPLAY_TEXT(l='Partid     ', m='Partid  ', s='partid')
            ittxt = Dgt.DISPLAY_TEXT(l='Game tempo ', m='Gametemp', s='gamtem')
            eutxt = Dgt.DISPLAY_TEXT(l='Par Denbora', m='ParDenbo', s='parden')
        if text_id == 'timemode_fischer_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Fischer    ', m='Fischer ', s='fischr')
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = entxt
        if text_id == 'info_version_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Version    ', m='Version ', s='vers  ')
            detxt = Dgt.DISPLAY_TEXT(l='Version    ', m='Version ', s='vers  ')
            nltxt = Dgt.DISPLAY_TEXT(l='Versie     ', m='Versie  ', s='versie')
            frtxt = Dgt.DISPLAY_TEXT(l='Version    ', m='Version ', s='vers  ')
            estxt = Dgt.DISPLAY_TEXT(l='Version    ', m='Version ', s='vers  ')
            ittxt = Dgt.DISPLAY_TEXT(l='Versione   ', m='Versione', s='versio')
            eutxt = Dgt.DISPLAY_TEXT(l='Bertsioa   ', m='Bertsioa', s='bertsi')
        if text_id == 'info_ipadr_menu':
            entxt = Dgt.DISPLAY_TEXT(l='IP adr     ', m='IP adr  ', s='ip adr')
            detxt = Dgt.DISPLAY_TEXT(l='IP adr     ', m='IP adr  ', s='ip adr')
            nltxt = Dgt.DISPLAY_TEXT(l='IP address ', m='IP adr  ', s='ip adr')
            frtxt = Dgt.DISPLAY_TEXT(l='Adr IP     ', m='Adr IP  ', s='adr ip')
            estxt = Dgt.DISPLAY_TEXT(l='IP dir     ', m='IP dir  ', s='ip dir')
            ittxt = Dgt.DISPLAY_TEXT(l='ind IP     ', m='ind IP  ', s='ind ip')
            eutxt = Dgt.DISPLAY_TEXT(l='IP Helbidea', m='IP Helbi', s='ip hel')
        if text_id == 'info_battery_menu':
            entxt = Dgt.DISPLAY_TEXT(l='BT battery ', m='Battery ', s='bt bat')
            detxt = Dgt.DISPLAY_TEXT(l='BT Batterie', m='Batterie', s='bt bat')
            nltxt = Dgt.DISPLAY_TEXT(l='BT batterij', m='batterij', s='bt bat')
            frtxt = Dgt.DISPLAY_TEXT(l='BT batterie', m='batterie', s='bt bat')
            estxt = Dgt.DISPLAY_TEXT(l='BT bateria ', m='bateria ', s='bt bat')
            ittxt = Dgt.DISPLAY_TEXT(l='BT batteria', m='batteria', s='bt bat')
            eutxt = Dgt.DISPLAY_TEXT(l='BT bateria ', m='bateria ', s='bt bat')
        if text_id == 'system_sound_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Sound      ', m='Sound   ', s='sound ')
            detxt = Dgt.DISPLAY_TEXT(l='Toene      ', m='Toene   ', s='toene ')
            nltxt = Dgt.DISPLAY_TEXT(l='Geluid     ', m='Geluid  ', s='geluid')
            frtxt = Dgt.DISPLAY_TEXT(l='Sons       ', m='Sons    ', s='sons  ')
            estxt = Dgt.DISPLAY_TEXT(l='Sonido     ', m='Sonido  ', s='sonido')
            ittxt = Dgt.DISPLAY_TEXT(l='Suoni      ', m='Suoni   ', s='suoni ')
            eutxt = Dgt.DISPLAY_TEXT(l='Soinua     ', m='Soinua  ', s='soinua')
        if text_id == 'system_language_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Language   ', m='Language', s='lang  ')
            detxt = Dgt.DISPLAY_TEXT(l='Sprache    ', m='Sprache ', s='sprach')
            nltxt = Dgt.DISPLAY_TEXT(l='Taal       ', m='Taal    ', s='taal  ')
            frtxt = Dgt.DISPLAY_TEXT(l='Langue     ', m='Langue  ', s='langue')
            estxt = Dgt.DISPLAY_TEXT(l='Idioma     ', m='Idioma  ', s='idioma')
            ittxt = Dgt.DISPLAY_TEXT(l='Lingua     ', m='Lingua  ', s='lingua')
            eutxt = Dgt.DISPLAY_TEXT(l='Hizkuntza  ', m='Hizkuntz', s='Hizkun')
        if text_id == 'system_logfile_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Log file   ', m='Log file', s='logfil')
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Log file   ', m='Log file', s='logfil')
        if text_id == 'system_info_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Information', m='Informat', s='inform')
            detxt = Dgt.DISPLAY_TEXT(l='Information', m='Informat', s='inform')
            nltxt = Dgt.DISPLAY_TEXT(l='Informatie ', m='Informat', s='inform')
            frtxt = Dgt.DISPLAY_TEXT(l='Information', m='Informat', s='inform')
            estxt = Dgt.DISPLAY_TEXT(l='Informacion', m='Informac', s='inform')
            ittxt = Dgt.DISPLAY_TEXT(l='Informazion', m='Informaz', s='inform')
            eutxt = Dgt.DISPLAY_TEXT(l='Informazioa', m='Informaz', s='inform')
        if text_id == 'system_voice_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Voice      ', m='Voice   ', s='voice ')
            detxt = Dgt.DISPLAY_TEXT(l='Stimme     ', m='Stimme  ', s='stimme')
            nltxt = Dgt.DISPLAY_TEXT(l='Stem       ', m='Stem    ', s='stem  ')
            frtxt = Dgt.DISPLAY_TEXT(l='Voix       ', m='Voix    ', s='voix  ')
            estxt = Dgt.DISPLAY_TEXT(l='Voz        ', m='Voz     ', s='voz   ')
            ittxt = Dgt.DISPLAY_TEXT(l='Voce       ', m='Voce    ', s='voce  ')
            eutxt = Dgt.DISPLAY_TEXT(l='Ahotsa     ', m='Ahotsa  ', s='Ahotsa')
        if text_id == 'system_display_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Display    ', m='Display ', s='dsplay')
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Pantaila   ', m='Pantaila', s='pantai')
        if text_id == 'gameresult_mate':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='mate       ', m='mate    ', s='mate  ') 
            detxt = Dgt.DISPLAY_TEXT(l='Schachmatt ', m='Matt    ', s='matt  ') # WD
            nltxt = Dgt.DISPLAY_TEXT(l='mat        ', m='mat     ', s='mat   ')
            frtxt = Dgt.DISPLAY_TEXT(l='mat        ', m='mat     ', s='mat   ')
            estxt = Dgt.DISPLAY_TEXT(l='mate       ', m='mate    ', s='mate  ')
            ittxt = Dgt.DISPLAY_TEXT(l='matto      ', m='matto   ', s='matto ')
            eutxt = Dgt.DISPLAY_TEXT(l='Matea      ', m='Matea   ', s='matea ')
        if text_id == 'gameresult_stalemate':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='stalemate  ', m='stalemat', s='stale ')
            detxt = Dgt.DISPLAY_TEXT(l='Patt       ', m='Patt    ', s='patt  ')
            nltxt = Dgt.DISPLAY_TEXT(l='patstelling', m='pat     ', s='pat   ')
            frtxt = Dgt.DISPLAY_TEXT(l='pat        ', m='pat     ', s='pat   ')
            estxt = Dgt.DISPLAY_TEXT(l='ahogado    ', m='ahogado ', s='ahogad')
            ittxt = Dgt.DISPLAY_TEXT(l='stallo     ', m='stallo  ', s='stallo')
            eutxt = Dgt.DISPLAY_TEXT(l='Itota      ', m='Itota   ', s='Itota ')
        if text_id == 'gameresult_time':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='time       ', m='time    ', s='time  ')
            detxt = Dgt.DISPLAY_TEXT(l='Zeit       ', m='Zeit    ', s='zeit  ')
            nltxt = Dgt.DISPLAY_TEXT(l='tyd        ', m='tyd     ', s='tyd   ')
            frtxt = Dgt.DISPLAY_TEXT(l='tombe      ', m='tombe   ', s='tombe ')
            estxt = Dgt.DISPLAY_TEXT(l='tiempo     ', m='tiempo  ', s='tiempo')
            ittxt = Dgt.DISPLAY_TEXT(l='tempo      ', m='tempo   ', s='tempo ')
            eutxt = Dgt.DISPLAY_TEXT(l='Denbora    ', m='denbora ', s='denbor')
        if text_id == 'gameresult_material':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='material   ', m='material', s='materi')
            detxt = Dgt.DISPLAY_TEXT(l='Material   ', m='Material', s='materi')
            nltxt = Dgt.DISPLAY_TEXT(l='materiaal  ', m='material', s='materi')
            frtxt = Dgt.DISPLAY_TEXT(l='materiel   ', m='materiel', s='materl')
            estxt = Dgt.DISPLAY_TEXT(l='material   ', m='material', s='mater ')
            ittxt = Dgt.DISPLAY_TEXT(l='materiale  ', m='material', s='materi')
            eutxt = Dgt.DISPLAY_TEXT(l='materiala  ', m='material', s='materi')
        if text_id == 'gameresult_moves':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='75 moves   ', m='75 moves', s='75 mov')
            detxt = Dgt.DISPLAY_TEXT(l='75 Zuege   ', m='75 Zuege', s='75 zug')
            nltxt = Dgt.DISPLAY_TEXT(l='75 zetten  ', m='75zetten', s='75 zet')
            frtxt = Dgt.DISPLAY_TEXT(l='75 mouv    ', m='75 mouv ', s='75 mvt')
            estxt = Dgt.DISPLAY_TEXT(l='75 mov     ', m='75 mov  ', s='75 mov')
            ittxt = Dgt.DISPLAY_TEXT(l='75 mosse   ', m='75 mosse', s='75 mos')
            eutxt = Dgt.DISPLAY_TEXT(l='75 mugimend', m='75 mugim', s='75 mug')
        if text_id == 'gameresult_repetition':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='repetition ', m='rep pos ', s='reppos')
            detxt = Dgt.DISPLAY_TEXT(l='Wiederholg ', m='Wiederhg', s='wdrhlg')
            nltxt = Dgt.DISPLAY_TEXT(l='zetherhalin', m='herhalin', s='herhal')
            frtxt = Dgt.DISPLAY_TEXT(l='3ieme rep  ', m='3iem rep', s=' 3 rep')
            estxt = Dgt.DISPLAY_TEXT(l='repeticion ', m='repite 3', s='rep 3 ')
            ittxt = Dgt.DISPLAY_TEXT(l='3 ripetiz  ', m='3 ripeti', s='3 ripe')
            eutxt = Dgt.DISPLAY_TEXT(l='3 errepikak', m='3 errepi', s='3 erre')
        if text_id == 'gameresult_abort':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='abort game ', m='abort   ', s='abort ')
            detxt = Dgt.DISPLAY_TEXT(l='Spl Abbruch', m='Abbruch ', s='abbrch')
            nltxt = Dgt.DISPLAY_TEXT(l='afbreken   ', m='afbreken', s='afbrek')
            frtxt = Dgt.DISPLAY_TEXT(l='sortir     ', m='sortir  ', s='sortir')
            estxt = Dgt.DISPLAY_TEXT(l='abortar    ', m='abortar ', s='abort ')
            ittxt = Dgt.DISPLAY_TEXT(l='interrompi ', m='interrom', s='interr')
            eutxt = Dgt.DISPLAY_TEXT(l='Bertan Behe', m='BertanBe', s='bertan')
        if text_id == 'gameresult_white':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='W wins     ', m='W wins  ', s='w wins')
            detxt = Dgt.DISPLAY_TEXT(l='W gewinnt  ', m='W Gewinn', s=' w gew')
            nltxt = Dgt.DISPLAY_TEXT(l='wit wint   ', m='wit wint', s='w wint')
            frtxt = Dgt.DISPLAY_TEXT(l='B gagne    ', m='B gagne ', s='b gagn')
            estxt = Dgt.DISPLAY_TEXT(l='B ganan    ', m='B ganan ', s='b gana')
            ittxt = Dgt.DISPLAY_TEXT(l='B vince    ', m='B vince ', s='b vinc')
            eutxt = Dgt.DISPLAY_TEXT(l='Z irabazle ', m='Z irabaz', s='Z irab')
        if text_id == 'gameresult_black':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='B wins     ', m='B wins  ', s='b wins')
            detxt = Dgt.DISPLAY_TEXT(l='S gewinnt  ', m='S Gewinn', s=' s gew')
            nltxt = Dgt.DISPLAY_TEXT(l='zwart wint ', m='zw wint ', s='z wint')
            frtxt = Dgt.DISPLAY_TEXT(l='N gagne    ', m='N gagne ', s='n gagn')
            estxt = Dgt.DISPLAY_TEXT(l='N ganan    ', m='N ganan ', s='n gana')
            ittxt = Dgt.DISPLAY_TEXT(l='N vince    ', m='N vince ', s='n vinc')
            eutxt = Dgt.DISPLAY_TEXT(l='B irabazle ', m='B irabaz', s='b irab')
        if text_id == 'gameresult_draw':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='draw       ', m='draw    ', s='draw  ')
            detxt = Dgt.DISPLAY_TEXT(l='Remis      ', m='Remis   ', s='remis ')
            nltxt = Dgt.DISPLAY_TEXT(l='remise     ', m='remise  ', s='remise')
            frtxt = Dgt.DISPLAY_TEXT(l='nulle      ', m='nulle   ', s='nulle ')
            estxt = Dgt.DISPLAY_TEXT(l='tablas     ', m='tablas  ', s='tablas')
            ittxt = Dgt.DISPLAY_TEXT(l='patta      ', m='patta   ', s='patta ')
            eutxt = Dgt.DISPLAY_TEXT(l='Berdinketa ', m='berdinke', s='Berdin')
        if text_id == 'playmode_white_user':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='player W   ', m='player W', s='white ')
            detxt = Dgt.DISPLAY_TEXT(l='Spieler W  ', m='SpielerW', s='splr w')
            nltxt = Dgt.DISPLAY_TEXT(l='speler wit ', m='speler W', s='splr w')
            frtxt = Dgt.DISPLAY_TEXT(l='joueur B   ', m='joueur B', s='blancs')
            estxt = Dgt.DISPLAY_TEXT(l='jugador B  ', m='jugad B ', s='juga b')
            ittxt = Dgt.DISPLAY_TEXT(l='gioc bianco', m='gi bianc', s='gioc b')
            eutxt = Dgt.DISPLAY_TEXT(l='Jokalaria Z', m='joka.  Z', s='joka z')
        if text_id == 'playmode_black_user':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='player B   ', m='player B', s='black ')
            detxt = Dgt.DISPLAY_TEXT(l='Spieler S  ', m='SpielerS', s='splr s')
            nltxt = Dgt.DISPLAY_TEXT(l='speler zw  ', m='speler z', s='splr z')
            frtxt = Dgt.DISPLAY_TEXT(l='joueur n   ', m='joueur n', s='noirs ')
            estxt = Dgt.DISPLAY_TEXT(l='jugador n  ', m='jugad n ', s='juga n')
            ittxt = Dgt.DISPLAY_TEXT(l='gioc nero  ', m='gi nero ', s='gioc n')
            eutxt = Dgt.DISPLAY_TEXT(l='Jokalaria B', m='joka.  B', s='joka b')
        if text_id == 'language_en_menu':
            entxt = Dgt.DISPLAY_TEXT(l='English    ', m='English ', s='englsh')
            detxt = Dgt.DISPLAY_TEXT(l='Englisch   ', m='Englisch', s='en    ')
            nltxt = Dgt.DISPLAY_TEXT(l='Engels     ', m='Engels  ', s='engels')
            frtxt = Dgt.DISPLAY_TEXT(l='Anglais    ', m='Anglais ', s='anglai')
            estxt = Dgt.DISPLAY_TEXT(l='Ingles     ', m='Ingles  ', s='ingles')
            ittxt = Dgt.DISPLAY_TEXT(l='Inglese    ', m='Inglese ', s='ingles')
            eutxt = Dgt.DISPLAY_TEXT(l='Ingelesea  ', m='Ingelesa', s='ingele')
        if text_id == 'language_de_menu':
            entxt = Dgt.DISPLAY_TEXT(l='German     ', m='German  ', s='german')
            detxt = Dgt.DISPLAY_TEXT(l='Deutsch    ', m='Deutsch ', s='de    ')
            nltxt = Dgt.DISPLAY_TEXT(l='Duits      ', m='Duits   ', s='duits ')
            frtxt = Dgt.DISPLAY_TEXT(l='Allemand   ', m='Allemand', s='allema')
            estxt = Dgt.DISPLAY_TEXT(l='Aleman     ', m='Aleman  ', s='aleman')
            ittxt = Dgt.DISPLAY_TEXT(l='Tedesco    ', m='Tedesco ', s='tedesc')
            eutxt = Dgt.DISPLAY_TEXT(l='Alemana    ', m='Alemana ', s='Aleman')
        if text_id == 'language_nl_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Dutch      ', m='Dutch   ', s='dutch ')
            detxt = Dgt.DISPLAY_TEXT(l='Niederldsch', m='Niederl ', s='nl    ')
            nltxt = Dgt.DISPLAY_TEXT(l='Nederlands ', m='Nederl  ', s='nederl')
            frtxt = Dgt.DISPLAY_TEXT(l='Neerlandais', m='Neerlnd ', s='neer  ')
            estxt = Dgt.DISPLAY_TEXT(l='Holandes   ', m='Holandes', s='holand')
            ittxt = Dgt.DISPLAY_TEXT(l='Olandese   ', m='Olandese', s='olande')
            eutxt = Dgt.DISPLAY_TEXT(l='Nederlander', m='Nederlan', s='nederl')
        if text_id == 'language_fr_menu':
            entxt = Dgt.DISPLAY_TEXT(l='French     ', m='French  ', s='french')
            detxt = Dgt.DISPLAY_TEXT(l='Franzosisch', m='Franzsch', s='fr    ')
            nltxt = Dgt.DISPLAY_TEXT(l='Frans      ', m='Frans   ', s='frans ')
            frtxt = Dgt.DISPLAY_TEXT(l='Francais   ', m='Francais', s='france')
            estxt = Dgt.DISPLAY_TEXT(l='Frances    ', m='Frances ', s='franc ')
            ittxt = Dgt.DISPLAY_TEXT(l='Francese   ', m='Francese', s='france')
            eutxt = Dgt.DISPLAY_TEXT(l='Frantsesa  ', m='Frantses', s='frants')
        if text_id == 'language_es_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Spanish    ', m='Spanish ', s='spanis')
            detxt = Dgt.DISPLAY_TEXT(l='Spanisch   ', m='Spanisch', s='es    ')
            nltxt = Dgt.DISPLAY_TEXT(l='Spaans     ', m='Spaans  ', s='spaans')
            frtxt = Dgt.DISPLAY_TEXT(l='Espagnol   ', m='Espagnol', s='espag ')
            estxt = Dgt.DISPLAY_TEXT(l='Espanol    ', m='Espanol ', s='esp   ')
            ittxt = Dgt.DISPLAY_TEXT(l='Spagnolo   ', m='Spagnolo', s='spagno')
            eutxt = Dgt.DISPLAY_TEXT(l='Gaztelania ', m='Gaztelan', s='gaztel')
        if text_id == 'language_it_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Italian    ', m='Italian ', s='italia')
            detxt = Dgt.DISPLAY_TEXT(l='Italienisch', m='Italisch', s='it    ')
            nltxt = Dgt.DISPLAY_TEXT(l='Italiaans  ', m='Italiaan', s='italia')
            frtxt = Dgt.DISPLAY_TEXT(l='Italien    ', m='Italien ', s='ital  ')
            estxt = Dgt.DISPLAY_TEXT(l='Italiano   ', m='Italiano', s='italia')
            ittxt = Dgt.DISPLAY_TEXT(l='Italiano   ', m='Italiano', s='italia')
            eutxt = Dgt.DISPLAY_TEXT(l='Italiera   ', m='Italiera', s='italie')
        if text_id == 'language_eu_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Basque     ', m='Basque  ', s='basque')
            detxt = Dgt.DISPLAY_TEXT(l='Baskisch   ', m='Baskisch', s='Baskis')
            nltxt = Dgt.DISPLAY_TEXT(l='Bask       ', m='Bask    ', s='Bask  ')
            frtxt = Dgt.DISPLAY_TEXT(l='Basque     ', m='Basque  ', s='basque')
            estxt = Dgt.DISPLAY_TEXT(l='LenguaVasca', m='LenVasca', s='vasco ')
            ittxt = Dgt.DISPLAY_TEXT(l='Basco      ', m='Basco   ', s='basco ')
            eutxt = Dgt.DISPLAY_TEXT(l='Euskara    ', m='Euskara ', s='euskar')
        if text_id == 'beep_off_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Never      ', m='Never   ', s='never ')
            detxt = Dgt.DISPLAY_TEXT(l='Nie        ', m='Nie     ', s='nie   ')
            nltxt = Dgt.DISPLAY_TEXT(l='Nooit      ', m='Nooit   ', s='nooit ')
            frtxt = Dgt.DISPLAY_TEXT(l='Jamais     ', m='Jamais  ', s='jamais')
            estxt = Dgt.DISPLAY_TEXT(l='Nunca      ', m='Nunca   ', s='nunca ')
            ittxt = Dgt.DISPLAY_TEXT(l='Mai        ', m='Mai     ', s='mai   ')
            eutxt = Dgt.DISPLAY_TEXT(l='Inoiz ez   ', m='Inoiz ez', s='sekula')
        if text_id == 'beep_some_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Sometimes  ', m='Some    ', s='sonne ')
            detxt = Dgt.DISPLAY_TEXT(l='Manchmal   ', m='Manchmal', s='manch ')
            nltxt = Dgt.DISPLAY_TEXT(l='Soms       ', m='Soms    ', s='sons  ')
            frtxt = Dgt.DISPLAY_TEXT(l='Parfois    ', m='Parfois ', s='parfoi')
            estxt = Dgt.DISPLAY_TEXT(l='A veces    ', m='A veces ', s='aveces')
            ittxt = Dgt.DISPLAY_TEXT(l='a volte    ', m='a volte ', s='avolte')
            eutxt = Dgt.DISPLAY_TEXT(l='Batzuetan  ', m='Batzueta', s='batzue')
        if text_id == 'beep_on_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Always     ', m='Always  ', s='always')
            detxt = Dgt.DISPLAY_TEXT(l='Immer      ', m='Immer   ', s='immer ')
            nltxt = Dgt.DISPLAY_TEXT(l='Altyd      ', m='Altyd   ', s='altyd ')
            frtxt = Dgt.DISPLAY_TEXT(l='Toujours   ', m='Toujours', s='toujou')
            estxt = Dgt.DISPLAY_TEXT(l='Siempre    ', m='Siempre ', s='siempr')
            ittxt = Dgt.DISPLAY_TEXT(l='Sempre     ', m='Sempre  ', s='sempre')
            eutxt = Dgt.DISPLAY_TEXT(l='Beti       ', m='Beti    ', s='beti  ')
        if text_id == 'oklang':
            entxt = Dgt.DISPLAY_TEXT(l='ok language', m='ok lang ', s='oklang')
            detxt = Dgt.DISPLAY_TEXT(l='ok Sprache ', m='okSprach', s='ok spr')
            nltxt = Dgt.DISPLAY_TEXT(l='ok taal    ', m='ok taal ', s='oktaal')
            frtxt = Dgt.DISPLAY_TEXT(l='ok langue  ', m='okLangue', s='oklang')
            estxt = Dgt.DISPLAY_TEXT(l='ok idioma  ', m='okIdioma', s='oklang')
            ittxt = Dgt.DISPLAY_TEXT(l='lingua ok  ', m='okLingua', s='okling')
            eutxt = Dgt.DISPLAY_TEXT(l='ok hizkuntz', m='okHizkun', s='okhizk')
        if text_id == 'oklogfile':
            entxt = Dgt.DISPLAY_TEXT(l='ok log file', m='oklogfil', s='ok log')
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = entxt
        if text_id == 'voice_speed_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Voice speed', m='Vc speed', s='vspeed')
            detxt = Dgt.DISPLAY_TEXT(l='StimmGeschw', m='StmGesch', s='stmges')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Ahots abiad', m='Ahos abi', s='ahoabi')
        if text_id == 'voice_speed':
            entxt = Dgt.DISPLAY_TEXT(l='VoiceSpeed' + msg, m='Vspeed ' + msg, s='v spe' + msg)
            detxt = Dgt.DISPLAY_TEXT(l='StmGeschw ' + msg, m='StmGes ' + msg, s='stm g' + msg)
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxtc
            eutxt = Dgt.DISPLAY_TEXT(l='Ahots Abia' + msg, m='AhotsAbi' + msg, s='a ab' + msg)
        if text_id == 'okspeed':
            entxt = Dgt.DISPLAY_TEXT(l='ok voice sp', m='ok speed', s='ok spe')
            detxt = Dgt.DISPLAY_TEXT(l='ok StmGesch', m='okStmGes', s='okstmg')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='ok ahots ab', m='ok abiad', s='ok abi')
        if text_id == 'voice_volume_menu': #WD
            entxt = Dgt.DISPLAY_TEXT(l='VoiceVolume', m='VoiceVol', s='voivol')
            detxt = Dgt.DISPLAY_TEXT(l='Lautstaerke', m='Lautstr ', s='lautst')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='AhotsBolume', m='AhotsBol', s='AhoBol')
        if text_id == 'voice_volume': #WD
            entxt = Dgt.DISPLAY_TEXT(l='VoiceVol ' + msg, m='Volume' + msg, s='vol ' + msg)
            detxt = Dgt.DISPLAY_TEXT(l='Volume   ' + msg, m='Volume' + msg, s='vol ' + msg)
            nltxt = entxt 
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Ahots Bol ' + msg, m='Bolume' + msg, s='bol ' + msg)
        if text_id == 'okvolume': #WD
            entxt = Dgt.DISPLAY_TEXT(l='ok volume  ', m='ok vol  ', s='ok vol')
            detxt = Dgt.DISPLAY_TEXT(l='ok Volume  ', m='ok vol  ', s='ok vol')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='ok bolumena', m='ok bol  ', s='ok bol')
        if text_id == 'voice_user_menu':
            entxt = Dgt.DISPLAY_TEXT(l='User voice ', m='UserVoic', s='user v')
            detxt = Dgt.DISPLAY_TEXT(l='Spieler Stm', m='Splr Stm', s='splr s')
            nltxt = Dgt.DISPLAY_TEXT(l='Speler Stem', m='SplrStem', s='splr s')
            frtxt = Dgt.DISPLAY_TEXT(l='Joueur Voix', m='JourVoix', s='jour v')
            estxt = Dgt.DISPLAY_TEXT(l='Jugador Voz', m='JugadVoz', s='juga v')
            ittxt = Dgt.DISPLAY_TEXT(l='Giocat Voce', m='GiocVoce', s='gioc v')
            eutxt = Dgt.DISPLAY_TEXT(l='Joka Ahotsa', m='JokAhots', s='joka a')
        if text_id == 'voice_comp_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Pico voice ', m='PicoVoic', s='pico v')
            detxt = Dgt.DISPLAY_TEXT(l='PicoChs Stm', m='Pico Stm', s='pico v')
            nltxt = Dgt.DISPLAY_TEXT(l='PicoChsStem', m='PicoStem', s='pico s')
            frtxt = Dgt.DISPLAY_TEXT(l='PicoChsVoix', m='PicoVoix', s='pico v')
            estxt = Dgt.DISPLAY_TEXT(l='PicoChs Voz', m='Pico Voz', s='pico v')
            ittxt = Dgt.DISPLAY_TEXT(l='PicoChsVoce', m='PicoVoce', s='pico v')
            eutxt = Dgt.DISPLAY_TEXT(l='Pico Ahotsa', m='PicAhots', s='pico a')
        if text_id == 'okvoice':
            # wait = True
            entxt = Dgt.DISPLAY_TEXT(l='ok Voice   ', m='ok Voice', s='ok voc')
            detxt = Dgt.DISPLAY_TEXT(l='ok Stimme  ', m='okStimme', s='ok stm')
            nltxt = Dgt.DISPLAY_TEXT(l='ok Stem    ', m='ok Stem ', s='okstem')
            frtxt = Dgt.DISPLAY_TEXT(l='ok Voix    ', m='ok Voix ', s='okvoix')
            estxt = Dgt.DISPLAY_TEXT(l='ok Voz     ', m='ok Voz  ', s='ok voz')
            ittxt = Dgt.DISPLAY_TEXT(l='ok Voce    ', m='ok Voce ', s='okvoce')
            eutxt = Dgt.DISPLAY_TEXT(l='ok Ahotsa  ', m='ok Ahots', s='okahot')
        if text_id == 'voice_on':
            entxt = Dgt.DISPLAY_TEXT(l='Voice  on  ', m='Voice on', s='vc  on')
            detxt = Dgt.DISPLAY_TEXT(l='Stimme ein ', m='Stim ein', s='st ein')
            nltxt = Dgt.DISPLAY_TEXT(l='Stem aan   ', m='Stem aan', s='st aan')
            frtxt = Dgt.DISPLAY_TEXT(l='Voix allume', m='Voix ete', s='vo ete')
            estxt = Dgt.DISPLAY_TEXT(l='Voz encend ', m='Voz ence', s='vz enc')
            ittxt = Dgt.DISPLAY_TEXT(l='Voce attiva', m='Voce att', s='vc att')
            eutxt = Dgt.DISPLAY_TEXT(l='AhotsaGaitu', m='Ahots On', s='aho on')
        if text_id == 'voice_off':
            entxt = Dgt.DISPLAY_TEXT(l='Voice off  ', m='Voiceoff', s='vc off')
            detxt = Dgt.DISPLAY_TEXT(l='Stimme aus ', m='Stim aus', s='st aus')
            nltxt = Dgt.DISPLAY_TEXT(l='Stem uit   ', m='Stem uit', s='st uit')
            frtxt = Dgt.DISPLAY_TEXT(l='Voix eteint', m='Voix ete', s='vo ete')
            estxt = Dgt.DISPLAY_TEXT(l='Voz apagada', m='Voz apag', s='vz apa')
            ittxt = Dgt.DISPLAY_TEXT(l='Voce spenta', m='Voce spe', s='vc spe')
            eutxt = Dgt.DISPLAY_TEXT(l='Ahotsa Ez  ', m='Ahots ez', s='aho ez')
        if text_id == 'okvolume': #WD
            entxt = Dgt.DISPLAY_TEXT(l='ok Volume  ', m='okVolume', s='ok vol')
            detxt = Dgt.DISPLAY_TEXT(l='ok Lautst  ', m='okLautst', s='ok Lau')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='ok Bolumena', m='okBolume', s='ok bol')
        if text_id == 'voice_volume_menu': #WD
            entxt = Dgt.DISPLAY_TEXT(l='VoiceVolume', m='Vc vol ', s='vc vo')
            detxt = Dgt.DISPLAY_TEXT(l='Lautstrarke', m='Lautstr ', s='laut')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='AhotsBolume', m='AhoBolu ', s='a bolu')            
        if text_id == 'display_ponder_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Ponder intv', m='PondIntv', s='ponint')
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Hausn tarte', m='HausTart', s='haustar')
        if text_id == 'okponder':
            entxt = Dgt.DISPLAY_TEXT(l='ok pondIntv', m='okPondIv', s='ok int')
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='ok HausTart', m='okHausTar', s='ok tar')
        if text_id == 'ponder_interval':
            entxt = Dgt.DISPLAY_TEXT(l='Pondr intv' + msg, m='PondrIv' + msg, s='p int' + msg)
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Haus Tarte' + msg, m='HausTar' + msg, s='h tar' + msg)
        if text_id == 'display_confirm_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Confirm msg', m='Confirm ', s='confrm')
            detxt = Dgt.DISPLAY_TEXT(l='Zugbestaetg', m='Zugbestg', s='zugbes')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='BaieztatuMez', m='Baiezta', s='baiezt')
        if text_id == 'display_capital_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Cap Letters', m='Capital ', s='captal')
            detxt = Dgt.DISPLAY_TEXT(l='Buchstaben ', m='Buchstab', s='buchst')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='LetraLarriz', m='Let Larr', s='larriz')
        if text_id == 'display_notation_menu':
            entxt = Dgt.DISPLAY_TEXT(l='Mv Notation', m='Notation', s='notati')
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Mg Notazioa', m='Notazioa', s='notazi')
        if text_id == 'okconfirm':
            entxt = Dgt.DISPLAY_TEXT(l='ok confirm ', m='okConfrm', s='okconf')
            detxt = Dgt.DISPLAY_TEXT(l='ok Zugbest ', m='okZugbes', s='ok bes')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='ok baiezta.', m='okBaiezt', s='okbaie')
        if text_id == 'confirm_on':
            entxt = Dgt.DISPLAY_TEXT(l='Confirm  on', m='Conf  on', s='cnf on')
            detxt = Dgt.DISPLAY_TEXT(l='Zugbest ein', m='Best ein', s='besein')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Baiezt. Bai', m='Bai.  on', s='bai on')
        if text_id == 'confirm_off':
            entxt = Dgt.DISPLAY_TEXT(l='Confirm off', m='Conf off', s='cnfoff')
            detxt = Dgt.DISPLAY_TEXT(l='Zugbest aus', m='Best aus', s='besaus')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Baiezt. ez ', m='Bai.  ez', s='bai ez')
        if text_id == 'okcapital':
            entxt = Dgt.DISPLAY_TEXT(l='ok Capital ', m='ok Capt ', s='ok cap')
            detxt = Dgt.DISPLAY_TEXT(l='ok Buchstab', m='ok Bstab', s='ok bst')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='ok Larriz  ', m='okLarriz', s='ok lar')
        if text_id == 'capital_on':
            entxt = Dgt.DISPLAY_TEXT(l='Capital  on', m='Capt  on', s='cap on')
            detxt = Dgt.DISPLAY_TEXT(l='Buchstb ein', m='Bstb ein', s='bstein')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Larriz  bai', m='LarrizOn', s='lar on')
        if text_id == 'capital_off':
            entxt = Dgt.DISPLAY_TEXT(l='Capital off', m='Capt off', s='capoff')
            detxt = Dgt.DISPLAY_TEXT(l='Buchstb aus', m='Bstb aus', s='bstaus')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Larriz   ez', m='LarrizEz', s='lar ez')
        if text_id == 'oknotation':
            entxt = Dgt.DISPLAY_TEXT(l='ok Notation', m='ok Notat', s='ok  nt')
            detxt = Dgt.DISPLAY_TEXT(l='ok Notation', m='ok Notat', s='ok  nt')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='ok Notazioa', m='ok Notaz', s='ok  nt')
        if text_id == 'notation_short':
            entxt = Dgt.DISPLAY_TEXT(l='Notat short', m='Nt short', s='short ')
            detxt = Dgt.DISPLAY_TEXT(l='Notatn kurz', m='Ntn kurz', s='ntkurz')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Notaz labur', m='Nt labur', s='labur ')
        if text_id == 'notation_long':
            entxt = Dgt.DISPLAY_TEXT(l='Notat  long', m='Nt  long', s='  long')
            detxt = Dgt.DISPLAY_TEXT(l='Notatn lang', m='Ntn lang', s='ntlang')
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='Notaz luzea', m='Nt luzea', s='luzea ')
        if text_id == 'tc_fixed':
            entxt = Dgt.DISPLAY_TEXT(l='Move time' + msg, m='Move t' + msg, s='mov ' + msg)
            detxt = Dgt.DISPLAY_TEXT(l='Zugzeit  ' + msg, m='Zug z ' + msg, s='zug ' + msg)
            nltxt = Dgt.DISPLAY_TEXT(l='Zet tyd  ' + msg, m='Zet t ' + msg, s='zet ' + msg)
            frtxt = Dgt.DISPLAY_TEXT(l='Mouv     ' + msg, m='Mouv  ' + msg, s='mouv' + msg)
            estxt = Dgt.DISPLAY_TEXT(l='Mov      ' + msg, m='Mov   ' + msg, s='mov ' + msg)
            ittxt = Dgt.DISPLAY_TEXT(l='Moss temp' + msg, m='Moss t' + msg, s='mos ' + msg)
            eutxt = Dgt.DISPLAY_TEXT(l='Mug denbo' + msg, m='Mug de' + msg, s='mug ' + msg)
        if text_id == 'tc_blitz':
            entxt = Dgt.DISPLAY_TEXT(l='Game time' + msg, m='Game t' + msg, s='game' + msg)
            detxt = Dgt.DISPLAY_TEXT(l='Spielzeit' + msg, m='Spielz' + msg, s='spl ' + msg)
            nltxt = Dgt.DISPLAY_TEXT(l='Spel tyd ' + msg, m='Spel t' + msg, s='spel' + msg)
            frtxt = Dgt.DISPLAY_TEXT(l='Partie   ' + msg, m='Partie' + msg, s='part' + msg)
            estxt = Dgt.DISPLAY_TEXT(l='Partid   ' + msg, m='Partid' + msg, s='part' + msg)
            ittxt = Dgt.DISPLAY_TEXT(l='Game temp' + msg, m='Game t' + msg, s='game' + msg)
            eutxt = Dgt.DISPLAY_TEXT(l='Joku denb' + msg, m='Joku d' + msg, s='joku' + msg)
        if text_id == 'tc_fisch':
            entxt = Dgt.DISPLAY_TEXT(l='Fischr' + msg, m='Fsh' + msg, s='f' + msg)
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = entxt
        if text_id == 'noboard':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='no e-' + msg, m='no' + msg, s=msg)
            detxt = entxt
            nltxt = entxt
            frtxt = entxt
            estxt = entxt
            ittxt = entxt
            eutxt = Dgt.DISPLAY_TEXT(l='ez e-' + msg, m='ez' + msg, s=msg)
        if text_id == 'update':
            entxt = Dgt.DISPLAY_TEXT(l='updating pc', m='updating', s='update')
            detxt = entxt
            nltxt = entxt
            frtxt = Dgt.DISPLAY_TEXT(l='actualisePc', m='actualis', s='actual')
            estxt = Dgt.DISPLAY_TEXT(l='actualizoPc', m='actualiz', s='actual')
            ittxt = Dgt.DISPLAY_TEXT(l='aggiornare ', m='aggiorPc', s='aggior')
            eutxt = Dgt.DISPLAY_TEXT(l='egunera. pc', m='egunera.', s='eguner')
        if text_id == 'updt_version':
            wait = True
            entxt = Dgt.DISPLAY_TEXT(l='Version ' + msg, m='Vers ' + msg, s='ver' + msg)
            detxt = Dgt.DISPLAY_TEXT(l='Version ' + msg, m='Vers ' + msg, s='ver' + msg)
            nltxt = Dgt.DISPLAY_TEXT(l='Versie  ' + msg, m='Vers ' + msg, s='ver' + msg)
            frtxt = Dgt.DISPLAY_TEXT(l='Version ' + msg, m='Vers ' + msg, s='ver' + msg)
            estxt = Dgt.DISPLAY_TEXT(l='Version ' + msg, m='Vers ' + msg, s='ver' + msg)
            ittxt = Dgt.DISPLAY_TEXT(l='Versione' + msg, m='Vers ' + msg, s='ver' + msg)
            eutxt = Dgt.DISPLAY_TEXT(l='Bertsioa' + msg, m='Bert ' + msg, s='ber' + msg)
        if text_id == 'bat_percent':
            entxt = Dgt.DISPLAY_TEXT(l='battery ' + msg, m='battr' + msg, s='bat' + msg)
            detxt = Dgt.DISPLAY_TEXT(l='Batterie' + msg, m='Battr' + msg, s='bat' + msg)
            nltxt = Dgt.DISPLAY_TEXT(l='batterij' + msg, m='battr' + msg, s='bat' + msg)
            frtxt = Dgt.DISPLAY_TEXT(l='batterie' + msg, m='battr' + msg, s='bat' + msg)
            estxt = Dgt.DISPLAY_TEXT(l='bateria ' + msg, m='battr' + msg, s='bat' + msg)
            ittxt = Dgt.DISPLAY_TEXT(l='batteria' + msg, m='battr' + msg, s='bat' + msg)
            eutxt = Dgt.DISPLAY_TEXT(l='bateria ' + msg, m='bater' + msg, s='bat' + msg)
        for txt in [entxt, detxt, nltxt, frtxt, estxt, ittxt, eutxt]:
            if txt:
                txt.wait = wait
                txt.beep = beep
                txt.maxtime = maxtime
                txt.devs = devs

        if entxt is None:
            beep = self.bl(BeepLevel.YES)
            entxt = Dgt.DISPLAY_TEXT(l=text_id, m=text_id, s=text_id, wait=False, beep=beep, maxtime=0, devs=devs)
            logging.warning('unknown text_id %s', text_id)
        if self.language == 'de' and detxt is not None:
            return self.capital_text(detxt)
        if self.language == 'nl' and nltxt is not None:
            return self.capital_text(nltxt)
        if self.language == 'fr' and frtxt is not None:
            return self.capital_text(frtxt)
        if self.language == 'es' and estxt is not None:
            return self.capital_text(estxt)
        if self.language == 'it' and ittxt is not None:
            return self.capital_text(ittxt)
        if self.language == 'eu' and eutxt is not None:
            return self.capital_text(eutxt)
        return self.capital_text(entxt)
