        private static void func5(string s_, ulong n_, out string r_sho_, out ulong r_amari_)
        {
            var rcs = new List<char>(new char[] { '0' });

            var s1 = s_;
            int loop_end = s1.Length + 1 - (20 - n_.ToString().Length);
            for (int i = n_.ToString().Length; i < loop_end; i++)
            {
                var s2 = s1.Substring(0, i);
                ulong n2 = 0;
                ulong.TryParse(s2.TrimStart('0'), out n2);
                rcs.Add((char)(n2 / n_ + (ulong)'0'));
                s1 = (n2 % n_).ToString().PadLeft(i, '0') + s1.Substring(i);
            }

            ulong n3 = 0;
            ulong.TryParse(s1.TrimStart('0'), out n3);
            ulong amari = n3 % n_;
            rcs.AddRange((n3 / n_).ToString().PadLeft(20 - n_.ToString().Length, '0').ToCharArray());

            //System.Diagnostics.Debug.WriteLine(new string(rcs.ToArray()));
            //System.Diagnostics.Debug.WriteLine(amari);

            r_sho_ = new string(rcs.ToArray());
            r_amari_ = amari;

            BigInteger bi1 = BigInteger.Parse(s_);
            BigInteger bi2 = n_;
            BigInteger bi3 = BigInteger.Parse(new string(rcs.ToArray()));

            //System.Diagnostics.Debug.WriteLine(bi1 / bi2);

            if (bi3 != bi1 / bi2)
            {
                System.Diagnostics.Debug.WriteLine(s_);

                System.Diagnostics.Debug.WriteLine("ERROR");
            }
        }
