--
-- PostgreSQL database dump
--

\restrict VrbCVmloGfuLbpqkSGn7TNo28kIO2PNDzOYjneIxH61MHcFj4LctZnyfYr8z6d6

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: customer_feedback; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.customer_feedback (id, author, comment) FROM stdin;
1	Aibek	Fast delivery, great price
2	Ainura	The box said "fragile", it was not packed well
3	Bakyt	Fine, thanks
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.customers (customer_id, name, email) FROM stdin;
3	Bakyt Mamatov	bakyt@mail.kg
1	Aibek Sharshenov	aibek@mail.kg
2	Ainura Toktomamatova	ainura.new@mail.kg
5	Bermet Asanova	bermet@mail.kg
6	Kanykei Osmonova	kanykei@mail.kg
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.departments (department_id, name) FROM stdin;
1	IT
2	Sales
3	HR
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.employees (employee_id, first_name, last_name, email, department, hire_date) FROM stdin;
1	Aibek	Sharshenov	aibek@corp.kg	IT	2021-03-15
2	Ainura	Toktomamatova	\N	IT	2022-07-01
3	Bakyt	Mamatov	bakyt@corp.kg	Sales	2020-01-10
4	Gulzat	Sultanova	gulzat@corp.kg	HR	2023-05-05
5	Nursultan	Isakov	nursultan@corp.kg	\N	\N
6	Meerim	Bekova	meerim@corp.kg	\N	\N
7	Tilek	Usubaliev	tilek@corp.kg	\N	\N
\.


--
-- Data for Name: log_table; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.log_table (id, message) FROM stdin;
1	log line 1
2	log line 2
3	log line 3
4	log line 4
5	log line 5
6	log line 6
7	log line 7
8	log line 8
9	log line 9
10	log line 10
11	log line 11
12	log line 12
13	log line 13
14	log line 14
15	log line 15
16	log line 16
17	log line 17
18	log line 18
19	log line 19
20	log line 20
21	log line 21
22	log line 22
23	log line 23
24	log line 24
25	log line 25
26	log line 26
27	log line 27
28	log line 28
29	log line 29
30	log line 30
31	log line 31
32	log line 32
33	log line 33
34	log line 34
35	log line 35
36	log line 36
37	log line 37
38	log line 38
39	log line 39
40	log line 40
41	log line 41
42	log line 42
43	log line 43
44	log line 44
45	log line 45
46	log line 46
47	log line 47
48	log line 48
49	log line 49
50	log line 50
51	log line 51
52	log line 52
53	log line 53
54	log line 54
55	log line 55
56	log line 56
57	log line 57
58	log line 58
59	log line 59
60	log line 60
61	log line 61
62	log line 62
63	log line 63
64	log line 64
65	log line 65
66	log line 66
67	log line 67
68	log line 68
69	log line 69
70	log line 70
71	log line 71
72	log line 72
73	log line 73
74	log line 74
75	log line 75
76	log line 76
77	log line 77
78	log line 78
79	log line 79
80	log line 80
81	log line 81
82	log line 82
83	log line 83
84	log line 84
85	log line 85
86	log line 86
87	log line 87
88	log line 88
89	log line 89
90	log line 90
91	log line 91
92	log line 92
93	log line 93
94	log line 94
95	log line 95
96	log line 96
97	log line 97
98	log line 98
99	log line 99
100	log line 100
101	log line 101
102	log line 102
103	log line 103
104	log line 104
105	log line 105
106	log line 106
107	log line 107
108	log line 108
109	log line 109
110	log line 110
111	log line 111
112	log line 112
113	log line 113
114	log line 114
115	log line 115
116	log line 116
117	log line 117
118	log line 118
119	log line 119
120	log line 120
121	log line 121
122	log line 122
123	log line 123
124	log line 124
125	log line 125
126	log line 126
127	log line 127
128	log line 128
129	log line 129
130	log line 130
131	log line 131
132	log line 132
133	log line 133
134	log line 134
135	log line 135
136	log line 136
137	log line 137
138	log line 138
139	log line 139
140	log line 140
141	log line 141
142	log line 142
143	log line 143
144	log line 144
145	log line 145
146	log line 146
147	log line 147
148	log line 148
149	log line 149
150	log line 150
151	log line 151
152	log line 152
153	log line 153
154	log line 154
155	log line 155
156	log line 156
157	log line 157
158	log line 158
159	log line 159
160	log line 160
161	log line 161
162	log line 162
163	log line 163
164	log line 164
165	log line 165
166	log line 166
167	log line 167
168	log line 168
169	log line 169
170	log line 170
171	log line 171
172	log line 172
173	log line 173
174	log line 174
175	log line 175
176	log line 176
177	log line 177
178	log line 178
179	log line 179
180	log line 180
181	log line 181
182	log line 182
183	log line 183
184	log line 184
185	log line 185
186	log line 186
187	log line 187
188	log line 188
189	log line 189
190	log line 190
191	log line 191
192	log line 192
193	log line 193
194	log line 194
195	log line 195
196	log line 196
197	log line 197
198	log line 198
199	log line 199
200	log line 200
201	log line 201
202	log line 202
203	log line 203
204	log line 204
205	log line 205
206	log line 206
207	log line 207
208	log line 208
209	log line 209
210	log line 210
211	log line 211
212	log line 212
213	log line 213
214	log line 214
215	log line 215
216	log line 216
217	log line 217
218	log line 218
219	log line 219
220	log line 220
221	log line 221
222	log line 222
223	log line 223
224	log line 224
225	log line 225
226	log line 226
227	log line 227
228	log line 228
229	log line 229
230	log line 230
231	log line 231
232	log line 232
233	log line 233
234	log line 234
235	log line 235
236	log line 236
237	log line 237
238	log line 238
239	log line 239
240	log line 240
241	log line 241
242	log line 242
243	log line 243
244	log line 244
245	log line 245
246	log line 246
247	log line 247
248	log line 248
249	log line 249
250	log line 250
251	log line 251
252	log line 252
253	log line 253
254	log line 254
255	log line 255
256	log line 256
257	log line 257
258	log line 258
259	log line 259
260	log line 260
261	log line 261
262	log line 262
263	log line 263
264	log line 264
265	log line 265
266	log line 266
267	log line 267
268	log line 268
269	log line 269
270	log line 270
271	log line 271
272	log line 272
273	log line 273
274	log line 274
275	log line 275
276	log line 276
277	log line 277
278	log line 278
279	log line 279
280	log line 280
281	log line 281
282	log line 282
283	log line 283
284	log line 284
285	log line 285
286	log line 286
287	log line 287
288	log line 288
289	log line 289
290	log line 290
291	log line 291
292	log line 292
293	log line 293
294	log line 294
295	log line 295
296	log line 296
297	log line 297
298	log line 298
299	log line 299
300	log line 300
301	log line 301
302	log line 302
303	log line 303
304	log line 304
305	log line 305
306	log line 306
307	log line 307
308	log line 308
309	log line 309
310	log line 310
311	log line 311
312	log line 312
313	log line 313
314	log line 314
315	log line 315
316	log line 316
317	log line 317
318	log line 318
319	log line 319
320	log line 320
321	log line 321
322	log line 322
323	log line 323
324	log line 324
325	log line 325
326	log line 326
327	log line 327
328	log line 328
329	log line 329
330	log line 330
331	log line 331
332	log line 332
333	log line 333
334	log line 334
335	log line 335
336	log line 336
337	log line 337
338	log line 338
339	log line 339
340	log line 340
341	log line 341
342	log line 342
343	log line 343
344	log line 344
345	log line 345
346	log line 346
347	log line 347
348	log line 348
349	log line 349
350	log line 350
351	log line 351
352	log line 352
353	log line 353
354	log line 354
355	log line 355
356	log line 356
357	log line 357
358	log line 358
359	log line 359
360	log line 360
361	log line 361
362	log line 362
363	log line 363
364	log line 364
365	log line 365
366	log line 366
367	log line 367
368	log line 368
369	log line 369
370	log line 370
371	log line 371
372	log line 372
373	log line 373
374	log line 374
375	log line 375
376	log line 376
377	log line 377
378	log line 378
379	log line 379
380	log line 380
381	log line 381
382	log line 382
383	log line 383
384	log line 384
385	log line 385
386	log line 386
387	log line 387
388	log line 388
389	log line 389
390	log line 390
391	log line 391
392	log line 392
393	log line 393
394	log line 394
395	log line 395
396	log line 396
397	log line 397
398	log line 398
399	log line 399
400	log line 400
401	log line 401
402	log line 402
403	log line 403
404	log line 404
405	log line 405
406	log line 406
407	log line 407
408	log line 408
409	log line 409
410	log line 410
411	log line 411
412	log line 412
413	log line 413
414	log line 414
415	log line 415
416	log line 416
417	log line 417
418	log line 418
419	log line 419
420	log line 420
421	log line 421
422	log line 422
423	log line 423
424	log line 424
425	log line 425
426	log line 426
427	log line 427
428	log line 428
429	log line 429
430	log line 430
431	log line 431
432	log line 432
433	log line 433
434	log line 434
435	log line 435
436	log line 436
437	log line 437
438	log line 438
439	log line 439
440	log line 440
441	log line 441
442	log line 442
443	log line 443
444	log line 444
445	log line 445
446	log line 446
447	log line 447
448	log line 448
449	log line 449
450	log line 450
451	log line 451
452	log line 452
453	log line 453
454	log line 454
455	log line 455
456	log line 456
457	log line 457
458	log line 458
459	log line 459
460	log line 460
461	log line 461
462	log line 462
463	log line 463
464	log line 464
465	log line 465
466	log line 466
467	log line 467
468	log line 468
469	log line 469
470	log line 470
471	log line 471
472	log line 472
473	log line 473
474	log line 474
475	log line 475
476	log line 476
477	log line 477
478	log line 478
479	log line 479
480	log line 480
481	log line 481
482	log line 482
483	log line 483
484	log line 484
485	log line 485
486	log line 486
487	log line 487
488	log line 488
489	log line 489
490	log line 490
491	log line 491
492	log line 492
493	log line 493
494	log line 494
495	log line 495
496	log line 496
497	log line 497
498	log line 498
499	log line 499
500	log line 500
501	log line 501
502	log line 502
503	log line 503
504	log line 504
505	log line 505
506	log line 506
507	log line 507
508	log line 508
509	log line 509
510	log line 510
511	log line 511
512	log line 512
513	log line 513
514	log line 514
515	log line 515
516	log line 516
517	log line 517
518	log line 518
519	log line 519
520	log line 520
521	log line 521
522	log line 522
523	log line 523
524	log line 524
525	log line 525
526	log line 526
527	log line 527
528	log line 528
529	log line 529
530	log line 530
531	log line 531
532	log line 532
533	log line 533
534	log line 534
535	log line 535
536	log line 536
537	log line 537
538	log line 538
539	log line 539
540	log line 540
541	log line 541
542	log line 542
543	log line 543
544	log line 544
545	log line 545
546	log line 546
547	log line 547
548	log line 548
549	log line 549
550	log line 550
551	log line 551
552	log line 552
553	log line 553
554	log line 554
555	log line 555
556	log line 556
557	log line 557
558	log line 558
559	log line 559
560	log line 560
561	log line 561
562	log line 562
563	log line 563
564	log line 564
565	log line 565
566	log line 566
567	log line 567
568	log line 568
569	log line 569
570	log line 570
571	log line 571
572	log line 572
573	log line 573
574	log line 574
575	log line 575
576	log line 576
577	log line 577
578	log line 578
579	log line 579
580	log line 580
581	log line 581
582	log line 582
583	log line 583
584	log line 584
585	log line 585
586	log line 586
587	log line 587
588	log line 588
589	log line 589
590	log line 590
591	log line 591
592	log line 592
593	log line 593
594	log line 594
595	log line 595
596	log line 596
597	log line 597
598	log line 598
599	log line 599
600	log line 600
601	log line 601
602	log line 602
603	log line 603
604	log line 604
605	log line 605
606	log line 606
607	log line 607
608	log line 608
609	log line 609
610	log line 610
611	log line 611
612	log line 612
613	log line 613
614	log line 614
615	log line 615
616	log line 616
617	log line 617
618	log line 618
619	log line 619
620	log line 620
621	log line 621
622	log line 622
623	log line 623
624	log line 624
625	log line 625
626	log line 626
627	log line 627
628	log line 628
629	log line 629
630	log line 630
631	log line 631
632	log line 632
633	log line 633
634	log line 634
635	log line 635
636	log line 636
637	log line 637
638	log line 638
639	log line 639
640	log line 640
641	log line 641
642	log line 642
643	log line 643
644	log line 644
645	log line 645
646	log line 646
647	log line 647
648	log line 648
649	log line 649
650	log line 650
651	log line 651
652	log line 652
653	log line 653
654	log line 654
655	log line 655
656	log line 656
657	log line 657
658	log line 658
659	log line 659
660	log line 660
661	log line 661
662	log line 662
663	log line 663
664	log line 664
665	log line 665
666	log line 666
667	log line 667
668	log line 668
669	log line 669
670	log line 670
671	log line 671
672	log line 672
673	log line 673
674	log line 674
675	log line 675
676	log line 676
677	log line 677
678	log line 678
679	log line 679
680	log line 680
681	log line 681
682	log line 682
683	log line 683
684	log line 684
685	log line 685
686	log line 686
687	log line 687
688	log line 688
689	log line 689
690	log line 690
691	log line 691
692	log line 692
693	log line 693
694	log line 694
695	log line 695
696	log line 696
697	log line 697
698	log line 698
699	log line 699
700	log line 700
701	log line 701
702	log line 702
703	log line 703
704	log line 704
705	log line 705
706	log line 706
707	log line 707
708	log line 708
709	log line 709
710	log line 710
711	log line 711
712	log line 712
713	log line 713
714	log line 714
715	log line 715
716	log line 716
717	log line 717
718	log line 718
719	log line 719
720	log line 720
721	log line 721
722	log line 722
723	log line 723
724	log line 724
725	log line 725
726	log line 726
727	log line 727
728	log line 728
729	log line 729
730	log line 730
731	log line 731
732	log line 732
733	log line 733
734	log line 734
735	log line 735
736	log line 736
737	log line 737
738	log line 738
739	log line 739
740	log line 740
741	log line 741
742	log line 742
743	log line 743
744	log line 744
745	log line 745
746	log line 746
747	log line 747
748	log line 748
749	log line 749
750	log line 750
751	log line 751
752	log line 752
753	log line 753
754	log line 754
755	log line 755
756	log line 756
757	log line 757
758	log line 758
759	log line 759
760	log line 760
761	log line 761
762	log line 762
763	log line 763
764	log line 764
765	log line 765
766	log line 766
767	log line 767
768	log line 768
769	log line 769
770	log line 770
771	log line 771
772	log line 772
773	log line 773
774	log line 774
775	log line 775
776	log line 776
777	log line 777
778	log line 778
779	log line 779
780	log line 780
781	log line 781
782	log line 782
783	log line 783
784	log line 784
785	log line 785
786	log line 786
787	log line 787
788	log line 788
789	log line 789
790	log line 790
791	log line 791
792	log line 792
793	log line 793
794	log line 794
795	log line 795
796	log line 796
797	log line 797
798	log line 798
799	log line 799
800	log line 800
801	log line 801
802	log line 802
803	log line 803
804	log line 804
805	log line 805
806	log line 806
807	log line 807
808	log line 808
809	log line 809
810	log line 810
811	log line 811
812	log line 812
813	log line 813
814	log line 814
815	log line 815
816	log line 816
817	log line 817
818	log line 818
819	log line 819
820	log line 820
821	log line 821
822	log line 822
823	log line 823
824	log line 824
825	log line 825
826	log line 826
827	log line 827
828	log line 828
829	log line 829
830	log line 830
831	log line 831
832	log line 832
833	log line 833
834	log line 834
835	log line 835
836	log line 836
837	log line 837
838	log line 838
839	log line 839
840	log line 840
841	log line 841
842	log line 842
843	log line 843
844	log line 844
845	log line 845
846	log line 846
847	log line 847
848	log line 848
849	log line 849
850	log line 850
851	log line 851
852	log line 852
853	log line 853
854	log line 854
855	log line 855
856	log line 856
857	log line 857
858	log line 858
859	log line 859
860	log line 860
861	log line 861
862	log line 862
863	log line 863
864	log line 864
865	log line 865
866	log line 866
867	log line 867
868	log line 868
869	log line 869
870	log line 870
871	log line 871
872	log line 872
873	log line 873
874	log line 874
875	log line 875
876	log line 876
877	log line 877
878	log line 878
879	log line 879
880	log line 880
881	log line 881
882	log line 882
883	log line 883
884	log line 884
885	log line 885
886	log line 886
887	log line 887
888	log line 888
889	log line 889
890	log line 890
891	log line 891
892	log line 892
893	log line 893
894	log line 894
895	log line 895
896	log line 896
897	log line 897
898	log line 898
899	log line 899
900	log line 900
901	log line 901
902	log line 902
903	log line 903
904	log line 904
905	log line 905
906	log line 906
907	log line 907
908	log line 908
909	log line 909
910	log line 910
911	log line 911
912	log line 912
913	log line 913
914	log line 914
915	log line 915
916	log line 916
917	log line 917
918	log line 918
919	log line 919
920	log line 920
921	log line 921
922	log line 922
923	log line 923
924	log line 924
925	log line 925
926	log line 926
927	log line 927
928	log line 928
929	log line 929
930	log line 930
931	log line 931
932	log line 932
933	log line 933
934	log line 934
935	log line 935
936	log line 936
937	log line 937
938	log line 938
939	log line 939
940	log line 940
941	log line 941
942	log line 942
943	log line 943
944	log line 944
945	log line 945
946	log line 946
947	log line 947
948	log line 948
949	log line 949
950	log line 950
951	log line 951
952	log line 952
953	log line 953
954	log line 954
955	log line 955
956	log line 956
957	log line 957
958	log line 958
959	log line 959
960	log line 960
961	log line 961
962	log line 962
963	log line 963
964	log line 964
965	log line 965
966	log line 966
967	log line 967
968	log line 968
969	log line 969
970	log line 970
971	log line 971
972	log line 972
973	log line 973
974	log line 974
975	log line 975
976	log line 976
977	log line 977
978	log line 978
979	log line 979
980	log line 980
981	log line 981
982	log line 982
983	log line 983
984	log line 984
985	log line 985
986	log line 986
987	log line 987
988	log line 988
989	log line 989
990	log line 990
991	log line 991
992	log line 992
993	log line 993
994	log line 994
995	log line 995
996	log line 996
997	log line 997
998	log line 998
999	log line 999
1000	log line 1000
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.orders (order_id, customer_id, order_date, total) FROM stdin;
1	1	2026-10-01	1220.00
2	2	2026-10-03	300.00
3	1	2026-10-20	20.00
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.products (product_id, name, category, price) FROM stdin;
1	Laptop	Electronics	1200.00
2	Mouse	Electronics	20.00
3	Desk	Furniture	300.00
10	Webcam	Electronics	59.90
12	Microphone	Electronics	120.00
13	Ring light	Accessories	35.50
\.


--
-- Data for Name: sales_data; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.sales_data (sale_id, region, amount, note) FROM stdin;
1	North	1200.00	\N
2	South	\N	late payment
3	East	560.50	\N
\.


--
-- Name: customer_feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.customer_feedback_id_seq', 3, true);


--
-- Name: departments_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.departments_department_id_seq', 3, true);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.employees_employee_id_seq', 7, true);


--
-- Name: log_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.log_table_id_seq', 1000, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 3, true);


--
-- PostgreSQL database dump complete
--

\unrestrict VrbCVmloGfuLbpqkSGn7TNo28kIO2PNDzOYjneIxH61MHcFj4LctZnyfYr8z6d6

