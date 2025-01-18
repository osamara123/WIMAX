<h1 align="center">WiMax PHY—Channel Coding</h1>
<p></p>

![Image](https://github.com/user-attachments/assets/345c1845-3ba4-4885-b95a-f48485295a94)

<ol>
  <li> Introduction: In this project, you are required to implement part of the PHY layer of a WiMax system; namely
“Channel Coding” (QPSK only) as described in section 8.4.9 in WiMax Standard (IEEE Std
802.16-2007). This part of the standard is explained in this document with some numeric
examples. WiMax PHY including “Channel Coding” has different parameters that are set by the
MAC layer. There are five different blocks within the “Chanel Coding”, each has different
parameters that might require several implementations. In this project you are only required to
implement one implementation per block..</li>
  <li> Channel Coding Channel coding procedures include:
1. Randomization (see 8.4.9.1).
2. FEC encoding (see 8.4.9.2).
3. Bit interleaving (see 8.4.9.3).
4. Repetition (see 8.4.9.5), only applied to QPSK modulation.
5. Modulation (see 8.4.9.4).
6. Orthogonal Frequency Division Multiple Access (OFDMA); Inverse Fast Fourier
Transform (iFFT)</li>
</ol>

<p></p>


<h3>Randomizer</h3>
<h4>A. Initializing Randomization</h4>
<ul>
  <li>The randomization is initialized on each FEC block.</li>
  <li>If the amount of data to transmit does not fit exactly the amount of data allocated, padding of <code>0xFF</code> (“1” only) shall be added to the end of the transmission block, up to the amount of data allocated.
    <ul>
      <li>Here, the amount of data allocated means the amount of data that corresponds to the amount of ⌊Ns / R⌋ slots, where <em>Ns</em> is the number of the slots allocated for the data burst and <em>R</em> is the repetition factor used.</li>
    </ul>
  </li>
</ul>

![Image](https://github.com/user-attachments/assets/6e3e3402-d80d-4903-8e30-3554c5196519)

<p></p>

![Image](https://github.com/user-attachments/assets/f54c5cd7-5d2d-4b6d-8004-5ddc3a2461f4)
![Image](https://github.com/user-attachments/assets/9c4060d3-d00b-452e-9254-10fa0bfd1144)
![Image](https://github.com/user-attachments/assets/a2fcfa30-ed86-463c-b50c-2936eb67c2f8)

<p></p>

<h4>FEC Encoder</h4>
<h5>A. Tail-Biting Convolutional Coding</h5>
<ul>
  <li>The coding method used as the mandatory scheme will be the tail-biting convolutional encoding specified in 8.4.9.2.1.</li>
  <li>The encoding block size shall depend on the number of slots allocated and the modulation specified for the current transmission.</li>
  <li>Concatenation of a number of slots shall be performed in order to make larger blocks of coding where it is possible, with the limitation of not exceeding the largest supported block size for the applied modulation and coding.</li>
  <li>Table 318 specifies the concatenation of slots for different allocations and modulations.</li>
  <li>The parameters in Table 317 and Table 318 shall apply to the CC encoding scheme.</li>
</ul>

<p></p>

![Image](https://github.com/user-attachments/assets/8e51567a-5e83-489a-9d9a-35d79ab5140b)
![Image](https://github.com/user-attachments/assets/05886869-d8c3-41e5-b10f-0a62b86a6429)
![Image](https://github.com/user-attachments/assets/75dd973e-0a3d-4cb1-ab77-f540f0b02a15)

<p></p>

<h3>Interleaving</h3>
<ul>
  <li>All encoded data bits shall be interleaved by a block interleaver with a block size corresponding to the number of coded bits per the encoded block size <em>Ncbps</em>.</li>
  <li>The interleaver is defined by a two-step permutation.
    <ul>
      <li>The first ensures that adjacent coded bits are mapped onto nonadjacent subcarriers.</li>
      <li>The second permutation ensures that adjacent coded bits are mapped alternately onto less or more significant bits of the constellation, thus avoiding long runs of lowly reliable bits.</li>
    </ul>
  </li>
  <li>Let <em>Ncpc</em> be the number of coded bits per subcarrier.
    <ul>
      <li>That is: 2, 4, or 6 for QPSK, 16-QAM, or 64-QAM, respectively.</li>
    </ul>
  </li>
  <li>Let <em>s</em> = <em>Ncpc</em>/2.</li>
  <li>Within a block of <em>Ncbps</em> bits at transmission, let:
    <ul>
      <li><em>k</em> be the index of the coded bit before the first permutation,</li>
      <li><em>mk</em> be the index of that coded bit after the first and before the second permutation,</li>
      <li><em>jk</em> be the index after the second permutation, just prior to modulation mapping, and</li>
      <li><em>d</em> be the modulo used for the permutation.</li>
    </ul>
  </li>
</ul>

 ![Image](https://github.com/user-attachments/assets/d152fbd7-4f6e-4507-96db-5cf14d2bbe73)
![Image](https://github.com/user-attachments/assets/a7d382c2-3595-4cb5-b181-bef9ef95d396)
![Image](https://github.com/user-attachments/assets/712265db-8530-463b-9fa8-bc68a06c2ecc)
![Image](https://github.com/user-attachments/assets/b954b97a-5046-496c-a783-667507d97451)
![Image](https://github.com/user-attachments/assets/a5f73da9-e190-4b63-822c-874d5240a004)
![Image](https://github.com/user-attachments/assets/5b98e76b-dce9-45fe-a1b5-d82b4cd1d39d)
![Image](https://github.com/user-attachments/assets/9cd22a98-2be7-44e0-90dc-91f95914fc08)
![Image](https://github.com/user-attachments/assets/bb6e5e37-0cf1-462d-91b9-514f16f4bed3)
![Image](https://github.com/user-attachments/assets/a8d9235c-39ac-4020-914d-8ee578baa138)
![Image](https://github.com/user-attachments/assets/44b564a4-53f9-45ee-a0ed-86bc63530db0)
![Image](https://github.com/user-attachments/assets/6d8b9841-6c29-40b2-b4c0-2de9969e7850)

 <p></p>

 <h3>Modulation</h3>
<h4>Data modulation</h4>
<ul>
  <li>After the repetition block, the data bits are entered serially to the constellation mapper.</li>
  <li>Gray-mapped QPSK and 16-QAM (as shown in Figure 263) shall be supported.</li>
  <li>The constellations (as shown in Figure 263) shall be normalized by multiplying the constellation point with the indicated factor <em>c</em> to achieve equal average power.</li>
</ul>

![Image](https://github.com/user-attachments/assets/b37b075b-2084-4589-b434-51cf548d5a91)
![Image](https://github.com/user-attachments/assets/68f62bfc-2bb7-45f5-a836-7974ec318c34)




<h4 >Bing Pong Buffer (Dual Port Ram)</h4>

![Image](https://github.com/user-attachments/assets/4947c8b1-3510-463e-937a-36bb07526b02)

<h4 >Using Ready/Valid Handshake</h4>

![Image](https://github.com/user-attachments/assets/0ed9287a-7066-4368-ab47-51a7aebdfd17)
![Image](https://github.com/user-attachments/assets/2343d6aa-15c0-47d0-933f-4ac3af16955b)
![Image](https://github.com/user-attachments/assets/bff78469-ac0d-4d98-a428-b24c3cd02e08)
