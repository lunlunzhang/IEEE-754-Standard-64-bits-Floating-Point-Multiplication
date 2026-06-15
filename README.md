# IEEE-754-Standard-64-bits-Floating-Point-Multiplication

## Problem Statement
Based on IEEE 754 standard, the double-precision numbers are stored in 64 bits: 1 for the sign, 11 for the exponent, and 52 for the fraction. An exponent is an unsigned number represented using the bias method with a bias of 1023. The fraction represents a number less than 1, but the significant of the floating-point number is 1 plus the  fraction part. 

In other words, if s stands for the sign bit, e is the biased exponent and f is the value of the fraction field, the number being represented is

<div align=center>
<img width="375" height="92" alt="image" src="https://github.com/user-attachments/assets/83c9a2f3-25f7-48f6-8c51-9bafb8ca0930" />
</div>

It is worthwhile to take notice that when the biased exponent is 2047, a zero fraction field represents infinity, and a nonzero fraction field represents **NaN** (Not a Number). When the biased exponent and the fraction field are both 0, then the number represented is exact 0.

For example, the following 64-bit word represents for <img width="250" height="37" alt="image" src="https://github.com/user-attachments/assets/94f4128f-f499-4072-a816-89ace208f906" />

<div align=center>
<img width="868" height="298" alt="image" src="https://github.com/user-attachments/assets/4065225e-7976-4a70-a8a3-0ad139a325ee" />
</div>

## Execution description

首先，需要先針對設計系統進行定義 :
1. Input Ports: CLK, RESET, ENABLE, DATA_IN[7:0]
2. Output Ports: DATA_OUT[7:0], READY
3. It is active-high synchronous reset architecture. 
4. The rounding mode is ″round to nearest″. In this mode, the representable value 
nearest to the infinitely precise result should be delivered. 
6. The output latency after data are input should be smaller than 60 clock cycles. 
7. The data are input when ENABLE is ″high″. If A[63:0] and B[63:0] are two double-precision numbers, it takes 16 clock cycles to input them to the multiplier. Also, for each double-precision number, the lower bytes are inputted first.

在本次設計中，除了設計浮點數乘法運算之外，需要遵守 IEEE-754 標準針對特例情況進行考量，如同表1.

<div align=center>
<img width="940" height="517" alt="image" src="https://github.com/user-attachments/assets/47b6a3dd-c105-44ec-abab-c8b2a98b1b70" />
</div>

在整體設計上主要以圖2.作為架構參考，首先會先對Input進行前處理拆分成三個部分分別為Sign \ Exponent \ Fraction ，接著分別會有對應的應算。

<div align=center>
<img width="451" height="650" alt="image" src="https://github.com/user-attachments/assets/7079db2a-34eb-46cb-86da-7c2ecba4a832" />
</div>

### Phase 1. Calculate 

Sign Bit : 進行XOR 運算。

<div align=center>
<img width="811" height="105" alt="image" src="https://github.com/user-attachments/assets/6c3a8945-c913-4d1a-beac-c0515570e9bb" />
</div>
Exponent : 進行相加，算法為兩個 exp 相加減去 1023 ，再由fraction 相乘的結果來判斷要不要進位。

<div align=center>
<img width="865" height="122" alt="image" src="https://github.com/user-attachments/assets/733089e5-8cbc-456c-b964-6c712890fe0c" />
</div>

Fraction : 進行相乘 (pipeline multiplier) 。由於這裡做乘法運算時，需要實作 52-bits x 52-bits 的乘法器，過於龐大，無法有效在 1 clock cycle 內運算完成，所以我這邊利用乘法直式的概念，將其變為104-bits 的加法器，直式的概念中總共需要做52 次的加法，首先會比較data_b 的 fraction 的每一個bit (data_b[i])，若是1則加 fraction_A 並 shift data_b[i] 的位置 (i的大小)，這裡我將其拆為 4 等分個別加13次，再將4等分相加，以加速運算的時間。

<div align=center>
<img width="796" height="228" alt="image" src="https://github.com/user-attachments/assets/e10453fc-1bd6-439d-b92c-5c2690df9684" />
  
圖 3.每個等分做加法

<img width="792" height="216" alt="image" src="https://github.com/user-attachments/assets/d8eb692a-ae8d-4ea7-a236-4282cce25de9" />

圖 4.將4等分相加並四捨五入
</div>

### Phase 2. IEEE.754 detection

<div align=center>
<img width="656" height="422" alt="image" src="https://github.com/user-attachments/assets/ea998f0a-353f-494e-a209-b3b96a6d828d" />

<img width="977" height="220" alt="image" src="https://github.com/user-attachments/assets/a3972dae-360b-46e4-8d4f-589c42cd76dc" />

圖 6.detect special case

<img width="974" height="185" alt="image" src="https://github.com/user-attachments/assets/beabb68e-51ec-44b1-8ede-ef559fa1d613" />

圖7.do special case
</div>

## Experimental results

### RTL Simulation 
General Case 

<div align=center>
<img width="772" height="259" alt="image" src="https://github.com/user-attachments/assets/a43d11ee-9739-4562-b3ab-18ef9a0570c7" />
</div>

Special Case 

<div align=center>
<img width="773" height="262" alt="image" src="https://github.com/user-attachments/assets/041a6ead-5e70-4400-9f59-deb3547d4e00" />
<img width="780" height="267" alt="image" src="https://github.com/user-attachments/assets/3fe80407-0203-4426-9776-45fd13b4a53c" />
<img width="785" height="258" alt="image" src="https://github.com/user-attachments/assets/cd2c8012-2e76-44e6-aa72-1808ae0b326b" />
</div>

###  Gate-Level Simulation 

Synthesis前設定Design Constraints

<div align=center>
<img width="645" height="177" alt="image" src="https://github.com/user-attachments/assets/ecfb7c8a-f4ed-4fa8-b372-ca486c5504f4" />
</div>

經過Synthesis後，Area / Timing / Power報告

<div align=center>
<img width="802" height="413" alt="image" src="https://github.com/user-attachments/assets/0891c570-c085-4bcf-9562-7950d1306238" />
<img width="807" height="404" alt="image" src="https://github.com/user-attachments/assets/42b7c141-5955-40d8-a4cf-c66ae3585fc5" />
</div>

###  Automatic Placement & Routing 

<div align=center>
<img width="699" height="613" alt="image" src="https://github.com/user-attachments/assets/7c0a8a5b-3dc2-4e44-9a86-ddc20938fdec" />

圖8.DRC error check

<img width="673" height="545" alt="image" src="https://github.com/user-attachments/assets/e087b832-6356-4947-aab9-8e090cba76c2" />

圖9.LVS error check

<img width="689" height="665" alt="image" src="https://github.com/user-attachments/assets/89bf5374-47d2-412c-91d1-71a98fd49684" />

圖10.IR drop result

<img width="532" height="561" alt="image" src="https://github.com/user-attachments/assets/074ead90-4b0d-403c-b14d-c3f8b95f6571" />

圖11.IR drop range

<img width="865" height="180" alt="image" src="https://github.com/user-attachments/assets/c166291c-2f5a-4931-a6c5-c9d8e528e947" />

圖12. APR時CLK constraint (0.5 ns)

<img width="865" height="131" alt="image" src="https://github.com/user-attachments/assets/9b47e14e-5395-4e8b-a7e2-9d4b31649906" />

圖13. APR Core size (66.7 μm * 64.72 μm)

<img width="865" height="212" alt="image" src="https://github.com/user-attachments/assets/33cd6034-55bf-4885-a969-f07e67e0feff" />

圖14. APR後 CHIP static power report
</div>

### Calibre DRC & LVS 

<div align=center>
<img width="865" height="156" alt="image" src="https://github.com/user-attachments/assets/731770f2-a58f-48fa-9b1a-4c7e10a230df" />
<img width="769" height="219" alt="image" src="https://github.com/user-attachments/assets/f0c9ae81-b61b-4ea6-bb87-d87c95600193" />

圖15.DRC check

<img width="865" height="376" alt="image" src="https://github.com/user-attachments/assets/af384297-14a4-4c00-8f43-ba27a945149a" />

圖16.LVS check

<img width="865" height="303" alt="image" src="https://github.com/user-attachments/assets/a7eedae6-4fb9-4b0e-96de-5ea4a26be0d9" />

圖 17.Calibre DRC check

<img width="770" height="455" alt="image" src="https://github.com/user-attachments/assets/f3e4f303-7a0d-41bf-8fbb-e498022c1ee4" />

圖 18.Calibre LVS check
</div>

