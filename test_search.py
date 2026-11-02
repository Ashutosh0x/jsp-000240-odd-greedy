"""Regression tests for Stein's odd greedy algorithm search engine."""

from fractions import Fraction
import unittest
import Search


class TestOddGreedy(unittest.TestCase):

    def test_unit_fractions_terminate_in_one_step(self):
        for b in [3, 5, 7, 9, 11, 101, 999]:
            res = Search.expand_odd_greedy(1, b)
            self.assertTrue(res["terminated"])
            self.assertEqual(res["steps"], 1)
            self.assertEqual(res["denominators"], [b])

    def test_distinct_vs_repeat_for_two_thirds(self):
        # Distinct denominator convention
        distinct_res = Search.expand_odd_greedy(2, 3, distinct=True)
        self.assertTrue(distinct_res["terminated"])
        self.assertEqual(distinct_res["steps"], 4)
        self.assertEqual(distinct_res["denominators"], [3, 5, 9, 45])
        # Repeat-allowed convention
        repeat_res = Search.expand_odd_greedy(2, 3, distinct=False)
        self.assertTrue(repeat_res["terminated"])
        self.assertEqual(repeat_res["steps"], 2)
        self.assertEqual(repeat_res["denominators"], [3, 3])

    def test_all_denominators_are_strictly_odd(self):
        for a, b in [(2, 5), (4, 7), (8, 15), (84, 85)]:
            res = Search.expand_odd_greedy(a, b)
            self.assertTrue(res["terminated"])
            for d in res["denominators"]:
                self.assertEqual(d % 2, 1, f"Denominator {d} is not odd!")

    def test_denominators_are_strictly_increasing(self):
        for a, b in [(2, 5), (4, 7), (8, 15), (84, 85), (191, 197)]:
            res = Search.expand_odd_greedy(a, b, distinct=True)
            self.assertTrue(res["terminated"])
            dens = res["denominators"]
            for i in range(len(dens) - 1):
                self.assertLess(dens[i], dens[i + 1])

    def test_exact_sum_matches_input_rational(self):
        test_fractions = [(2, 3), (2, 5), (3, 7), (4, 9), (5, 11), (84, 85)]
        for a, b in test_fractions:
            res = Search.expand_odd_greedy(a, b)
            self.assertTrue(res["terminated"])
            reconstructed = sum(Fraction(1, d) for d in res["denominators"])
            self.assertEqual(reconstructed, Fraction(a, b))

    def test_ordinary_greedy_numerator_bound(self):
        # Under ordinary odd greedy (min_d = 3 without history restriction),
        # the numerator of next remainder a*d - b is strictly less than 2*a.
        for a, b in [(2, 3), (4, 9), (7, 15), (13, 27), (84, 85)]:
            d = Search.next_odd_denominator(a, b, min_d=3)
            new_num = a * d - b
            self.assertGreaterEqual(new_num, 0)
            self.assertLess(new_num, 2 * a)

    def test_hardest_fraction_trajectory_84_85(self):
        res = Search.expand_odd_greedy(84, 85)
        self.assertTrue(res["terminated"])
        self.assertEqual(res["steps"], 18)
        self.assertEqual(res["denominators"][:6], [3, 5, 7, 9, 11, 13])
        self.assertGreater(res["max_denominator_bits"], 10000)


if __name__ == "__main__":
    unittest.main()
