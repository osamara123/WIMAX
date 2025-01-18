<h1 align="center">WiMax PHY—Channel Coding</h1>
<p></p>

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
 
 <p></p>

 <h3>Modulation7</h3>
<h4>A. Data modulation8</h4>
<ul>
  <li>After the repetition block, the data bits are entered serially to the constellation mapper.</li>
  <li>Gray-mapped QPSK and 16-QAM (as shown in Figure 263) shall be supported.</li>
  <li>The constellations (as shown in Figure 263) shall be normalized by multiplying the constellation point with the indicated factor <em>c</em> to achieve equal average power.</li>
</ul>
