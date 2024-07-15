-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 15 Jul 2024 pada 18.12
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_14228`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `input_pembelian` (IN `kd_brg` CHAR(5), IN `jml_brg` INT, IN `id_cus` CHAR(5))   begin
declare saldo_customer int;
declare harga_barang int;
declare subtotal int;
declare stok_barang int;

start transaction;

select saldo into saldo_customer
from customer
where id_customer = id_cus;

select harga into harga_barang
from barang
where kode_brg = kd_brg;

set subtotal = jml_brg * harga_barang;

if saldo_customer < subtotal then
	
	rollback;
	select 'Transaksi dibatalkan : Saldo anda tidak cukup;
;
';
else

	select stok into stok_barang
from barang
where kode_brg = kd_brg;

if stok_barang < jml_brg then

rollback;
select 'Transaksi dibatalkan : Stok barang tidak cukup';
else

update barang
set stok = stok - jml_brg
where kode_brg = kd_brg;

update customer
set saldo = saldo - subtotal
where id_customer = id_cus;

insert into pembelian(kode_brg, jumlah_brg, subtotal, id_customer)
values (kd_brg, jml_brg, subtotal, id_cus);

commit;
select 'Transaction commited successfully';
end if;
end if;
end$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `subtotal` (`kode` CHAR(5), `jml_brg` INT) RETURNS INT(11)  begin
declare harga_brg int;
declare subtotal int;
select harga into harga_brg from barang where kode_brg = kode;
set subtotal = harga_brg * jml_brg;
return subtotal;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `barang`
--

CREATE TABLE `barang` (
  `kode_brg` char(5) NOT NULL,
  `nama_brg` varchar(50) NOT NULL,
  `id_kategori` char(3) NOT NULL,
  `harga` int(11) DEFAULT NULL,
  `stok` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `barang`
--

INSERT INTO `barang` (`kode_brg`, `nama_brg`, `id_kategori`, `harga`, `stok`) VALUES
('E0001', 'Xiomi Smart TV A2 32 inc', 'ELK', 1800000, 10),
('E0002', 'Miyako Kipas Angin 12 inc putih', 'ELK', 195000, 15),
('E0003', 'Philips Setrika Uap Ungu', 'ELK', 330000, 11),
('E0004', 'Mesin Cuci AQUA 1 Tabung', 'ELK', 1900000, 10),
('P0001', 'velvet Junior Baju Anak', 'PKN', 40000, 8),
('P0002', 'Kaos Kerah Polo Shirt', 'PKN', 30000, 12),
('P0003', 'Seruni Blouse Panjang Putih', 'PKN', 150000, 12),
('S0001', 'Aerostreet 40-43 Tactical Hitam', 'SPT', 189900, 12),
('S0002', 'Sepatu NB New Balance 574 Legacy Black Hitam', 'SPT', 610000, 9),
('S0003', 'Sepatu Adidas', 'SPT', 300000, 10);

-- --------------------------------------------------------

--
-- Struktur dari tabel `customer`
--

CREATE TABLE `customer` (
  `id_customer` char(5) NOT NULL,
  `nama_customer` varchar(50) NOT NULL,
  `jns_kel` char(1) NOT NULL CHECK (`jns_kel` in ('L','P')),
  `alamat` varchar(255) DEFAULT NULL,
  `saldo` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `customer`
--

INSERT INTO `customer` (`id_customer`, `nama_customer`, `jns_kel`, `alamat`, `saldo`) VALUES
('C0001', 'Indra Wijaya', 'L', 'Jln Waru Timur', 170000),
('C0002', 'Shinta Cyntia', 'P', 'Jln Seroja Raya 5', 390000);

-- --------------------------------------------------------

--
-- Struktur dari tabel `kategori`
--

CREATE TABLE `kategori` (
  `id_kategori` char(3) NOT NULL,
  `nama_kategori` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kategori`
--

INSERT INTO `kategori` (`id_kategori`, `nama_kategori`) VALUES
('ELK', 'Elektronika'),
('PKN', 'Pakaian'),
('SPT', 'Sepatu');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pembelian`
--

CREATE TABLE `pembelian` (
  `id_pembelian` int(11) NOT NULL,
  `kode_brg` char(5) NOT NULL,
  `jumlah_brg` int(11) NOT NULL,
  `subtotal` int(11) DEFAULT NULL,
  `id_customer` char(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pembelian`
--

INSERT INTO `pembelian` (`id_pembelian`, `kode_brg`, `jumlah_brg`, `subtotal`, `id_customer`) VALUES
(1, 'E0003', 1, 330000, 'C0001'),
(2, 'S0002', 1, 610000, 'C0002');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`kode_brg`),
  ADD KEY `id_kategori` (`id_kategori`);

--
-- Indeks untuk tabel `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`id_customer`);

--
-- Indeks untuk tabel `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`id_kategori`);

--
-- Indeks untuk tabel `pembelian`
--
ALTER TABLE `pembelian`
  ADD PRIMARY KEY (`id_pembelian`),
  ADD KEY `kode_brg` (`kode_brg`),
  ADD KEY `id_customer` (`id_customer`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `pembelian`
--
ALTER TABLE `pembelian`
  MODIFY `id_pembelian` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `barang`
--
ALTER TABLE `barang`
  ADD CONSTRAINT `barang_ibfk_1` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id_kategori`);

--
-- Ketidakleluasaan untuk tabel `pembelian`
--
ALTER TABLE `pembelian`
  ADD CONSTRAINT `pembelian_ibfk_1` FOREIGN KEY (`kode_brg`) REFERENCES `barang` (`kode_brg`),
  ADD CONSTRAINT `pembelian_ibfk_2` FOREIGN KEY (`id_customer`) REFERENCES `customer` (`id_customer`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
