"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";

import type { TopicFile } from "@/lib/content";

import { saveTopic } from "./actions";

interface Props {
  topic: TopicFile;
  subjectCode: string;
  chapterCode: string;
  topicCode: string;
}

const DIFFICULTIES = ["easy", "medium", "hard"] as const;
const QTYPES = ["single", "multiple", "truefalse", "scenario"] as const;

export function TopicEditor({
  topic,
  subjectCode,
  chapterCode,
  topicCode,
}: Props) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [status, setStatus] = useState<string | null>(null);

  function onSubmit(form: FormData) {
    startTransition(async () => {
      const res = await saveTopic(subjectCode, chapterCode, topicCode, form);
      if (!res.ok) {
        setStatus(`Save failed: ${res.error ?? "unknown"}`);
        return;
      }
      setStatus(
        `Saved · ${res.saved?.flashcards ?? 0} flashcards · ${res.saved?.questions ?? 0} questions`,
      );
      router.refresh();
    });
  }

  return (
    <form action={onSubmit} className="space-y-10">
      <input
        type="hidden"
        name="flashcards_count"
        value={topic.flashcards.length}
      />
      <input
        type="hidden"
        name="questions_count"
        value={topic.questions.length}
      />

      <section>
        <h2 className="text-lg font-semibold mb-3">Topic</h2>
        <div className="grid gap-3">
          <Field label="Title">
            <input
              type="text"
              name="topic_title"
              defaultValue={topic.topic_title}
              className={inputCls}
            />
          </Field>
          <Field label="Summary">
            <textarea
              name="topic_summary"
              defaultValue={topic.topic_summary ?? ""}
              rows={2}
              className={inputCls}
            />
          </Field>
        </div>
      </section>

      <section>
        <div className="flex items-baseline justify-between mb-3">
          <h2 className="text-lg font-semibold">
            Flashcards ({topic.flashcards.length})
          </h2>
        </div>
        <ul className="space-y-4">
          {topic.flashcards.map((fc, i) => (
            <li
              key={i}
              className="rounded-lg border border-white/10 bg-white/[0.04] p-4"
            >
              <div className="flex items-baseline justify-between mb-2">
                <p className="text-xs uppercase tracking-widest text-ink-300">
                  Card #{i + 1}
                </p>
                <label className="text-xs text-ink-300 flex items-center gap-1.5">
                  <input
                    type="checkbox"
                    name={`fc_${i}_delete`}
                    value="1"
                    className="accent-white"
                  />
                  Delete on save
                </label>
              </div>
              <div className="grid sm:grid-cols-2 gap-3">
                <Field label="Front">
                  <textarea
                    name={`fc_${i}_front`}
                    defaultValue={fc.front}
                    rows={2}
                    className={inputCls}
                  />
                </Field>
                <Field label="Back">
                  <textarea
                    name={`fc_${i}_back`}
                    defaultValue={fc.back}
                    rows={2}
                    className={inputCls}
                  />
                </Field>
                <Field label="Hint">
                  <input
                    type="text"
                    name={`fc_${i}_hint`}
                    defaultValue={fc.hint ?? ""}
                    className={inputCls}
                  />
                </Field>
                <Field label="Tags (comma-separated)">
                  <input
                    type="text"
                    name={`fc_${i}_tags`}
                    defaultValue={fc.tags.join(", ")}
                    className={inputCls}
                  />
                </Field>
                <Field label="Difficulty">
                  <select
                    name={`fc_${i}_difficulty`}
                    defaultValue={fc.difficulty}
                    className={inputCls}
                  >
                    {DIFFICULTIES.map((d) => (
                      <option key={d} value={d}>
                        {d}
                      </option>
                    ))}
                  </select>
                </Field>
                <Field label="Source page">
                  <input
                    type="number"
                    name={`fc_${i}_page`}
                    defaultValue={fc.source_page ?? ""}
                    className={inputCls}
                  />
                </Field>
              </div>
            </li>
          ))}
        </ul>

        <details className="mt-4 rounded-lg border border-dashed border-white/15 p-4">
          <summary className="cursor-pointer text-sm text-ink-100">
            + Add new flashcard
          </summary>
          <div className="grid sm:grid-cols-2 gap-3 mt-3">
            <Field label="Front">
              <textarea
                name="fc_new_front"
                rows={2}
                className={inputCls}
              />
            </Field>
            <Field label="Back">
              <textarea name="fc_new_back" rows={2} className={inputCls} />
            </Field>
            <Field label="Hint">
              <input type="text" name="fc_new_hint" className={inputCls} />
            </Field>
            <Field label="Tags (comma-separated)">
              <input type="text" name="fc_new_tags" className={inputCls} />
            </Field>
            <Field label="Difficulty">
              <select
                name="fc_new_difficulty"
                defaultValue="medium"
                className={inputCls}
              >
                {DIFFICULTIES.map((d) => (
                  <option key={d} value={d}>
                    {d}
                  </option>
                ))}
              </select>
            </Field>
            <Field label="Source page">
              <input
                type="number"
                name="fc_new_page"
                className={inputCls}
              />
            </Field>
          </div>
        </details>
      </section>

      <section>
        <h2 className="text-lg font-semibold mb-3">
          Questions ({topic.questions.length})
        </h2>
        <ul className="space-y-4">
          {topic.questions.map((q, i) => (
            <li
              key={i}
              className="rounded-lg border border-white/10 bg-white/[0.04] p-4"
            >
              <input
                type="hidden"
                name={`q_${i}_opt_count`}
                value={q.options.length}
              />
              <div className="flex items-baseline justify-between mb-2">
                <p className="text-xs uppercase tracking-widest text-ink-300">
                  Question #{i + 1}
                </p>
                <label className="text-xs text-ink-300 flex items-center gap-1.5">
                  <input
                    type="checkbox"
                    name={`q_${i}_delete`}
                    value="1"
                    className="accent-white"
                  />
                  Delete on save
                </label>
              </div>
              <div className="grid sm:grid-cols-2 gap-3">
                <Field label="Stem" wide>
                  <textarea
                    name={`q_${i}_stem`}
                    defaultValue={q.stem}
                    rows={2}
                    className={inputCls}
                  />
                </Field>
                <Field label="Type">
                  <select
                    name={`q_${i}_qtype`}
                    defaultValue={q.qtype}
                    className={inputCls}
                  >
                    {QTYPES.map((t) => (
                      <option key={t} value={t}>
                        {t}
                      </option>
                    ))}
                  </select>
                </Field>
                <Field label="Difficulty">
                  <select
                    name={`q_${i}_difficulty`}
                    defaultValue={q.difficulty}
                    className={inputCls}
                  >
                    {DIFFICULTIES.map((d) => (
                      <option key={d} value={d}>
                        {d}
                      </option>
                    ))}
                  </select>
                </Field>
                <Field label="Source page">
                  <input
                    type="number"
                    name={`q_${i}_page`}
                    defaultValue={q.source_page ?? ""}
                    className={inputCls}
                  />
                </Field>
                <Field label="Tags (comma-separated)">
                  <input
                    type="text"
                    name={`q_${i}_tags`}
                    defaultValue={q.tags.join(", ")}
                    className={inputCls}
                  />
                </Field>
                <Field label="Explanation" wide>
                  <textarea
                    name={`q_${i}_explanation`}
                    defaultValue={q.explanation}
                    rows={2}
                    className={inputCls}
                  />
                </Field>
              </div>
              <div className="mt-3">
                <p className="text-xs uppercase tracking-widest text-ink-300 mb-2">
                  Options
                </p>
                <ul className="space-y-2">
                  {q.options.map((o, j) => (
                    <li
                      key={j}
                      className="grid grid-cols-[2rem_5rem_1fr_auto] gap-2 items-center"
                    >
                      <input
                        type="text"
                        name={`q_${i}_opt_${j}_label`}
                        defaultValue={o.label}
                        className={inputCls}
                      />
                      <span className="text-xs text-ink-400">label</span>
                      <input
                        type="text"
                        name={`q_${i}_opt_${j}_content`}
                        defaultValue={o.content}
                        className={inputCls}
                      />
                      <label className="text-xs text-ink-200 flex items-center gap-1.5">
                        <input
                          type="checkbox"
                          name={`q_${i}_opt_${j}_correct`}
                          value="1"
                          defaultChecked={o.is_correct}
                          className="accent-emerald-400"
                        />
                        correct
                      </label>
                    </li>
                  ))}
                </ul>
              </div>
            </li>
          ))}
        </ul>
      </section>

      <div className="sticky bottom-0 -mx-6 px-6 py-4 bg-black/40 backdrop-blur border-t border-white/10 flex items-center gap-4">
        <button
          type="submit"
          disabled={isPending}
          className="rounded-md bg-white text-black px-4 py-2 text-sm font-medium hover:bg-ink-100 disabled:opacity-60"
        >
          {isPending ? "Saving…" : "Save changes"}
        </button>
        {status && <p className="text-sm text-ink-200">{status}</p>}
      </div>
    </form>
  );
}

const inputCls =
  "w-full rounded-md bg-black/40 border border-white/10 px-3 py-1.5 text-sm focus:outline-none focus:border-white/40";

function Field({
  label,
  children,
  wide,
}: {
  label: string;
  children: React.ReactNode;
  wide?: boolean;
}) {
  return (
    <label className={wide ? "sm:col-span-2" : undefined}>
      <span className="block text-xs uppercase tracking-widest text-ink-300 mb-1">
        {label}
      </span>
      {children}
    </label>
  );
}
