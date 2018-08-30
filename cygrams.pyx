# distutils: language = c++

from libcpp.map cimport map
from libcpp.string cimport string


cdef class Cygrams(dict):

    cdef readonly int min_n, max_n

    def __init__(self, min_n, max_n):
        self.min_n = min_n
        self.max_n = max_n

    def build_topK(self, items, int min_df=100, int K=0):
        cdef int i, j, n, count, length
        cdef map[string,int] counts
        cdef string item_string
        for item in items:
            item_string = item.encode('utf-32')
            length = len(item)
            with nogil:
                for i in range(length - self.min_n):
                    n = self.max_n
                    if i + n > length:
                        n = length - i
                    for j in range(self.min_n, n):
                        counts[item_string.substr(i * 4, j * 4)] += 1
        ngrams = sorted((
            (-count, ngram)
            for ngram, count in counts
            if count >= min_df
        ))
        if K:
            for n, (count, ngram) in zip(range(K), ngrams):
                self[ngram.decode('utf-32')] = n
        else:
            for n, (count, ngram) in enumerate(ngrams):
                self[ngram.decode('utf-32')] = n
        return self
