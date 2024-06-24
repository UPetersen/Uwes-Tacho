# Uwes Tacho

Diese App zeigt die aktuelle Geschwindigkeit an, mit der das iPhone bzw. iPad gerade bewegt wird. 

<p align="center">
<img width="400" src="https://github.com/UPetersen/Uwes-Tacho/assets/10375483/64dd2582-abd9-462c-8d4d-e1298172f621">
</p>

Die obere, zentrale Anzeige erfolgt entsprechend des aktuellen Ortes, d.h. z.B. in km/h in Deutschland und in Meilen pro Stunde in den USA. 
Zusätzlich wird die in den vier Feldern darunter die Geschwindigkeit in den vier Einheiten Kilometer pro Stunde, Meilen pro Stunde, Knoten und Meter pro Sekunde angezeigt. 
Durch einen Touch auf eines dieser vier Felder wird die Einheit der oberen, zentralen Anzeige entsprechend umgeschaltet.

Zusätzlich wird die Genauigkeit der Geschwindigkeitsanzeige angegeben, z.B. "±0,72 km/h". 

## Beispielvideo

Nachfolgend noch ein Video der App. Die App wurde dafür im inneren eines Gebäudes gestartet, wo es keinen ausreichenden GPS-Emfpang gibt, und gleich danach wurde das iPhone aus dem Gebäude ins freie gebracht und mit Schrittgeschwindigkeit weiter bewegt. Entsprechend wird zunächst nur "---" angezeigt und nach kurzer Zeit erfolgt die Information dass der GPS-Emfpang nicht ausreichend ist. Danach, d.h. außerhalb des Gebäudes gibt es dann GPS-Empfang und sogleich verschwindet die Meldung und es wird die aktuelle (Schritt-) Geschwindigkeit angezeigt. Beispielhaft wird danach die Umschaltung der oberen Anzeige auf andere Einheiten dargestellt. Dazu wird zunächst durch Drücken der Meilen-pro-Stunde-Anzeige die obere Anzeige auf mph umgestellt (erste Flip-Animation) und danach, durch Drücken der Kilometer-Pro-Stunde-Anzeige, wird die obere Anzeige wieder auf km/h umgestellt (zweite Flip-Animation). Wird die App bei Bewegung, z.B. in einem fahrenden Fahrzeug gestartet, sieht man übrigens sofort die Zahlenwerte.


https://github.com/UPetersen/Uwes-Tacho/assets/10375483/f3aaf129-41b7-4171-90b0-da01dfa64aa7


## Woher kommen die Daten? 

Die angezeigte Geschwindigkeit und die zugehörige Genauigkeit werden in dieser Form von Apple zur Verfügung gestellt und sind nicht nachbehandelt. 

Die angezeigte Geschwindigkeitsgenauigkeit kann sehr variieren. Apple macht keine weiteren Angaben zu dieser Größe. 
Der kleinste Wert den ich bisher sehen konnte war ±0,72 km/h bzw. 0,2 m/s bei Fahrt in ebenem, freiem Gelände. 
Je nach Umgebungsbegebenheiten kann dieser Wert  deutlich größer sein: Z.B. hatte ich schon Werte von über 10 km/h bei einer Geschwindigkeit von 80 km/h auf einer Landstraße. 
Die tatsächliche Genauigkeit war dabei aber augenscheinlich wesentlich besser, als es der Zahlenwert vermuten ließe.

# Rechtliche Hinweise und Datenschutzerklärung
            
Es werden keine Daten und damit auch keine personenbezogenen Daten gespeichert.

Der Bestimmung des Standorts muss zugestimmt werden, damit die Geschwindigkeitsinformation des iPhones oder iPads abgerufen werden kann.

# Haftungsausschluss
            
Für die Richtigkeit der angezeigten Informationen wird keinerlei Haftung oder Gewähr übernommen. Bitte rechnen Sie damit, dass die App fehlerhaft sein kann.

# Lizenz

GNU GENERAL PUBLIC LICENSE [Version 3](https://github.com/UPetersen/Uwes-Tacho/blob/main/LICENSE).

