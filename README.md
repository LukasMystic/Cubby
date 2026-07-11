# Joey & Mia Story Data

Folder ini berisi data JSON untuk cerita interaktif bercabang **Joey & Mia** versi Bahasa Indonesia.

Data ini adalah konten cerita, bukan kode aplikasi. Struktur file dan ID teknis tetap mengikuti versi sebelumnya supaya aman untuk backend game.

## Lokasi

```text
data/stories/joey-mia/
```

## Struktur Alur

```text
opening.json
└── Pilihanmu
    ├── 1.json
    │   ├── 1A.json
    │   ├── 1B.json
    │   └── 1C.json
    │
    ├── 2.json
    │   ├── 2A.json
    │   ├── 2B.json
    │   └── 2C.json
    │
    └── 3.json
        ├── 3A.json
        ├── 3B.json
        │   ├── 3b(i).json
        │   └── 3b(ii).json
        └── 3C.json
```

## Catatan

- `main.json` adalah peta/router alur cerita.
- `opening.json` adalah awal cerita.
- Setiap file cabang punya `storybook_page` untuk layar storybook di akhir pilihan.
- Untuk path `3B(i)`, game menampilkan 3 halaman storybook: `3.json`, `3B.json`, lalu `3b(i).json`.
- Untuk path `3B(ii)`, game menampilkan 3 halaman storybook: `3.json`, `3B.json`, lalu `3b(ii).json`.

## Jangan Diubah

ID teknis seperti `branch_id`, `node_id`, `ending_id`, `connects_from`, `connects_to`, `target_file`, dan `choice_quality` tidak diterjemahkan agar backend tetap aman.
